-- ============================================================
-- 任务看板系统 · Supabase 数据库初始化脚本
-- 在 Supabase 的 SQL Editor 中粘贴并运行（Run）
-- 功能：创建 tasks 表 + 开启行级安全(RLS) + 查询/写入/删除策略
-- ============================================================

-- 1. 创建 tasks 表（字段与 kanban.html 中任务对象一一对应）
create table if not exists public.tasks (
  id            text primary key,          -- 任务编号，如 TASK-20260906-001
  user_id       uuid not null,             -- 所属用户（RLS 隔离依据）
  title         text not null,
  description   text not null default '',
  source        text not null default '',
  status        text not null default 'pending',  -- pending / processing / completed / cancelled
  "order"       integer not null default 0,       -- 列内排序
  cancel_reason text not null default '',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz                 -- NULL = 活跃；非NULL = 在回收站
);

-- 2. 索引：按用户 + 状态加速查询（看板按列分组）
create index if not exists tasks_user_status_idx
  on public.tasks (user_id, status);

-- 3. 开启行级安全（RLS）—— 核心安全边界
alter table public.tasks enable row level security;

-- 4. 创建策略：每个用户只能读写自己的任务
--    读取（含回收站）
create policy "Users can read their own tasks"
  on public.tasks
  for select
  using (auth.uid() = user_id);

--    新增
create policy "Users can insert their own tasks"
  on public.tasks
  for insert
  with check (auth.uid() = user_id);

--    更新
create policy "Users can update their own tasks"
  on public.tasks
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

--    删除（回收站清空时物理删除）
create policy "Users can delete their own tasks"
  on public.tasks
  for delete
  using (auth.uid() = user_id);

-- ============================================================
-- 完成。验证：可运行下面的查询，应返回空的 tasks 列表
--   select * from public.tasks;
-- ============================================================
