-- ============================================================
-- 川大吃什么 · Supabase 数据库配置
-- 在 Supabase 后台 → SQL Editor 中逐步执行以下命令
-- ============================================================

-- ----------------------------------------
-- 1. 创建投稿表（存储用户提交的新档口/菜品）
-- ----------------------------------------
CREATE TABLE IF NOT EXISTS submissions (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  type TEXT NOT NULL CHECK (type IN ('stall', 'dish')),
  stall_name TEXT,
  dish_name TEXT NOT NULL,
  price NUMERIC NOT NULL,
  campus TEXT DEFAULT '江安校区',
  group_name TEXT,
  parent_stall_id TEXT,
  image_url TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------
-- 2. 开启 submissions 表的 RLS
-- ----------------------------------------
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;

-- 允许任何人提交投稿
CREATE POLICY "anyone_can_submit" ON submissions
  FOR INSERT WITH CHECK (true);

-- 允许任何人读取（主页展示已通过的投稿需要）
CREATE POLICY "anyone_can_read" ON submissions
  FOR SELECT USING (true);

-- 允许任何人修改状态（审核后台需要，通过 admin.html 密码门保护）
CREATE POLICY "anyone_can_update" ON submissions
  FOR UPDATE USING (true);

-- ----------------------------------------
-- 3. 加固 ratings 表的 RLS（防止删改评分）
--    ⚠️ 如果之前没开 RLS，这步至关重要！
-- ----------------------------------------
ALTER TABLE ratings ENABLE ROW LEVEL SECURITY;

-- 删除可能存在的宽松策略（如果有的话）
-- DROP POLICY IF EXISTS "Enable read for all" ON ratings;
-- DROP POLICY IF EXISTS "Enable insert for all" ON ratings;

-- 只允许读取和新增，不允许修改和删除
CREATE POLICY "ratings_read_only" ON ratings
  FOR SELECT USING (true);

CREATE POLICY "ratings_insert_only" ON ratings
  FOR INSERT WITH CHECK (true);

-- 注意：不创建 UPDATE 和 DELETE 策略 = 任何人（包括你自己通过 API）
-- 都无法修改或删除已有的评分。如果你需要删除某条评分，
-- 需要去 Supabase 后台的 Table Editor 手动操作。

-- ----------------------------------------
-- 4. （可选）创建图片存储桶
--    在 Supabase 后台 → Storage → 新建 Bucket
--    名称：food-images
--    勾选 "Public bucket"
--    然后在 Policies 中添加：
--      - SELECT: 允许所有人 (true)
--      - INSERT: 允许所有人 (true)
--    之后用户可以直接上传图片并获取公开 URL
-- ----------------------------------------
