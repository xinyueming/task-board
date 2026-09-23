-- ============================================================
-- 任务时间线字段迁移 · 新增启动/完成/取消时间
-- 在 Supabase 的 SQL Editor 中粘贴并运行（Run）
-- ============================================================

-- 1. 新增三个时间戳列
alter table public.tasks add column if not exists started_at   timestamptz;  -- 启动时间（进入处理中）
alter table public.tasks add column if not exists completed_at timestamptz;  -- 完成时间（进入已完成）
alter table public.tasks add column if not exists cancelled_at timestamptz;  -- 取消时间（进入已取消）

-- 2. 历史数据回填
--    老任务没有这些时间戳，用 updated_at 作为最接近的代理值
--    （任务被改动到该状态时，updated_at 就是那个时刻）

-- 处理中的任务：回填启动时间
update public.tasks
   set started_at = coalesce(updated_at, created_at)
 where status = 'processing'
   and started_at is null;

-- 已完成的任务：回填完成时间
update public.tasks
   set completed_at = coalesce(updated_at, created_at)
 where status = 'completed'
   and completed_at is null;

-- 已取消的任务：回填取消时间
update public.tasks
   set cancelled_at = coalesce(updated_at, created_at)
 where status = 'cancelled'
   and cancelled_at is null;

-- 3. 索引：按用户 + 完成/取消时间筛选（统计口径用）
create index if not exists tasks_user_completed_idx
  on public.tasks (user_id, completed_at);
create index if not exists tasks_user_cancelled_idx
  on public.tasks (user_id, cancelled_at);

-- ============================================================
-- 完成。验证：
--   select status, count(*), count(started_at) as 有启动, count(completed_at) as 有完成, count(cancelled_at) as 有取消
--     from public.tasks group by status;
-- ============================================================
