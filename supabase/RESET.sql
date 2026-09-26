-- Puduu RESET: drop everything FULL_SCHEMA builds, child tables first.
-- Run this FIRST only if a previous run failed halfway (half-built DB).
-- Then run FULL_SCHEMA.sql fresh.
drop trigger if exists routines_bump on routines;
drop trigger if exists subtasks_bump on subtasks;
drop trigger if exists tasks_bump on tasks;
drop function if exists bump_updated_at();
drop table if exists moods;
drop table if exists routines;
drop table if exists subtasks;
drop table if exists tasks;
