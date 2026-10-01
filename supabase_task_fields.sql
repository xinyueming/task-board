-- ============================================================
-- 任务扩展字段迁移 · 优先级 / 负责人 / 部门 / 截止时间 / 标签
-- 在 Supabase 的 SQL Editor 中粘贴并运行（Run）
-- ============================================================

-- 1. 新增五个字段
alter table public.tasks add column if not exists priority   text not null default 'P2';   -- P0/P1/P2/P3
alter table public.tasks add column if not exists assignee   text not null default '';     -- 负责人
alter table public.tasks add column if not exists department text not null default '';     -- 所属部门
alter table public.tasks add column if not exists due_date   date;                          -- 截止时间
alter table public.tasks add column if not exists tags       text[] not null default '{}'; -- 任务标签

-- 2. 历史数据回填
--    部门：用现有的「客户来源」作为初值（语义最接近）
update public.tasks
   set department = source
 where (department is null or department = '')
   and coalesce(source, '') <> '';

--    优先级：统一给默认 P2（中）
update public.tasks
   set priority = 'P2'
 where priority is null or priority = '';

-- 3. 索引：按优先级/截止时间筛选
create index if not exists tasks_user_priority_idx on public.tasks (user_id, priority);
create index if not exists tasks_user_due_idx      on public.tasks (user_id, due_date);

-- ============================================================
-- 完成。验证：
--   select id, priority, assignee, department, due_date, tags from public.tasks limit 5;
-- ============================================================
