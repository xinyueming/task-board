-- ============================================================
-- AI 设置表（DeepSeek API Key / 模型选择）· 账号级存储
-- 在 Supabase 的 SQL Editor 中粘贴并运行（Run）
--
-- 注意：本方案按需求将 API Key 以明文存储，安全性依赖 RLS：
--       每个用户只能读写自己那一行（user_id = auth.uid()）。
-- ============================================================

create table if not exists public.user_settings (
  user_id      uuid primary key,                 -- 与 auth.users.id 对应
  deepseek_key text not null default '',         -- DeepSeek API Key（明文）
  model        text not null default 'deepseek-flash',  -- deepseek-flash / deepseek-v4-pro
  updated_at   timestamptz not null default now()
);

-- 开启行级安全（RLS）
alter table public.user_settings enable row level security;

-- 策略：每个用户只能读写自己的设置
drop policy if exists "Users can read own settings"   on public.user_settings;
drop policy if exists "Users can insert own settings" on public.user_settings;
drop policy if exists "Users can update own settings" on public.user_settings;
drop policy if exists "Users can delete own settings" on public.user_settings;

create policy "Users can read own settings"
  on public.user_settings for select
  using (auth.uid() = user_id);

create policy "Users can insert own settings"
  on public.user_settings for insert
  with check (auth.uid() = user_id);

create policy "Users can update own settings"
  on public.user_settings for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete own settings"
  on public.user_settings for delete
  using (auth.uid() = user_id);

-- ============================================================
-- 完成。验证：
--   select * from public.user_settings;
-- 应返回空结果（尚未有任何用户保存过设置）
-- ============================================================
