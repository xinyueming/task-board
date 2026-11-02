-- ============================================================
-- 任务分类（单选）+ 账号级自定义分类选项
-- 在 Supabase 的 SQL Editor 中粘贴并运行（Run）
--
-- 说明：
--   1. tasks.category —— 单个分类名，空字符串表示「未分类」
--   2. user_settings.categories —— 该账号自定义的分类选项列表（JSON 数组）
--      · 空数组 [] 表示「未自定义」，前端自动回落到内置预设：
--        生产任务 / 功能开发 / 流程维护 / 数据库维护 / 文件体系 / 技术支持 / 其他
--
-- 重要：前端新版本会读写这两列。如果只部署前端而不跑本脚本，
--       tasks 的整表 upsert 会因列不存在而返回 400，
--       导致所有任务保存失败。请务必先运行本脚本。
-- ============================================================

-- 1) 任务分类字段
alter table public.tasks
  add column if not exists category text not null default '';

-- 2) 账号级自定义分类选项
alter table public.user_settings
  add column if not exists categories jsonb not null default '[]'::jsonb;

-- ============================================================
-- 完成。验证（两条都应成功返回，不报 column does not exist）：
--   select category from public.tasks limit 1;
--   select categories from public.user_settings limit 1;
-- ============================================================
