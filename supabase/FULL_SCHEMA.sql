-- Puduu Supabase FULL SCHEMA v1 (MVP, single-user local-first + cloud sync).
-- RUN THIS ONE FILE in Dashboard > SQL Editor > New query > paste > Run.
-- Idempotent: safe to re-run. If a previous run failed halfway, run
-- RESET.sql FIRST, then this file fresh.
-- Mirrors drift tables in lib/core/db/puduu_db.dart 1:1.
-- RLS MVP posture: allow-all (same as berkah-pos mvp_all). Tighten to
-- auth.uid()-based policies after login flow ships.

-- ---------- tasks ----------
create table if not exists tasks (
  id text primary key,
  user_id uuid references auth.users(id) on delete cascade,
  title text not null,
  note text,
  duration_min int,
  scheduled_at timestamptz,
  color_index int not null default 0,
  status text not null default 'inbox',
  updated_at timestamptz not null default now()
);
alter table tasks add column if not exists user_id uuid references auth.users(id) on delete cascade;
alter table tasks add column if not exists note text;
alter table tasks add column if not exists duration_min int;
alter table tasks add column if not exists scheduled_at timestamptz;
alter table tasks add column if not exists color_index int not null default 0;
alter table tasks add column if not exists status text not null default 'inbox';
alter table tasks add column if not exists updated_at timestamptz not null default now();
create index if not exists tasks_status_idx on tasks (status);
create index if not exists tasks_user_idx on tasks (user_id);
create index if not exists tasks_updated_idx on tasks (updated_at desc);

-- ---------- subtasks ----------
create table if not exists subtasks (
  id text primary key,
  task_id text not null references tasks(id) on delete cascade,
  title text not null,
  timer_min int,
  done boolean not null default false,
  updated_at timestamptz not null default now()
);
alter table subtasks add column if not exists updated_at timestamptz not null default now();
create index if not exists subtasks_task_idx on subtasks (task_id);

-- ---------- routines ----------
create table if not exists routines (
  id text primary key,
  user_id uuid references auth.users(id) on delete cascade,
  name text not null,
  step_titles jsonb not null default '[]',
  rrule text not null default '',
  updated_at timestamptz not null default now()
);
alter table routines add column if not exists user_id uuid references auth.users(id) on delete cascade;
alter table routines add column if not exists updated_at timestamptz not null default now();
create index if not exists routines_user_idx on routines (user_id);

-- ---------- moods ----------
create table if not exists moods (
  day date primary key,
  user_id uuid references auth.users(id) on delete cascade,
  score int not null check (score between 1 and 5),
  note text
);
alter table moods add column if not exists user_id uuid references auth.users(id) on delete cascade;

-- ---------- RLS (MVP allow-all) ----------
alter table tasks enable row level security;
alter table subtasks enable row level security;
alter table routines enable row level security;
alter table moods enable row level security;

drop policy if exists mvp_all on tasks;
create policy mvp_all on tasks for all using (true) with check (true);
drop policy if exists mvp_all on subtasks;
create policy mvp_all on subtasks for all using (true) with check (true);
drop policy if exists mvp_all on routines;
create policy mvp_all on routines for all using (true) with check (true);
drop policy if exists mvp_all on moods;
create policy mvp_all on moods for all using (true) with check (true);

-- ---------- updated_at auto-bump ----------
create or replace function bump_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;
drop trigger if exists tasks_bump on tasks;
create trigger tasks_bump before update on tasks
  for each row execute function bump_updated_at();
drop trigger if exists subtasks_bump on subtasks;
create trigger subtasks_bump before update on subtasks
  for each row execute function bump_updated_at();
drop trigger if exists routines_bump on routines;
create trigger routines_bump before update on routines
  for each row execute function bump_updated_at();
