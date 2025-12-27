-- =========================================================
-- GearGuard - RBAC + RLS Policies
-- =========================================================

-- Helper function: check current user's role
create or replace function public.has_role(role_name text)
returns boolean
language sql
security definer
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role::text = role_name
  );
$$;

-- Enable RLS
alter table public.profiles enable row level security;
alter table public.equipment enable row level security;
alter table public.workcenters enable row level security;
alter table public.teams enable row level security;
alter table public.team_members enable row level security;
alter table public.maintenance_requests enable row level security;
alter table public.request_notes enable row level security;
alter table public.request_instructions enable row level security;
alter table public.request_worksheet_comments enable row level security;
alter table public.request_stage_history enable row level security;

-- -----------------------------
-- PROFILES POLICIES
-- -----------------------------
drop policy if exists "read own profile" on public.profiles;
create policy "read own profile"
on public.profiles
for select
using (id = auth.uid());

drop policy if exists "admin read all profiles" on public.profiles;
create policy "admin read all profiles"
on public.profiles
for select
using (has_role('ADMIN'));

drop policy if exists "admin update profiles" on public.profiles;
create policy "admin update profiles"
on public.profiles
for update
using (has_role('ADMIN'))
with check (has_role('ADMIN'));

-- -----------------------------
-- EQUIPMENT POLICIES
-- -----------------------------
drop policy if exists "read equipment" on public.equipment;
create policy "read equipment"
on public.equipment
for select
using (auth.uid() is not null);

drop policy if exists "manage equipment" on public.equipment;
create policy "manage equipment"
on public.equipment
for all
using (has_role('ADMIN') or has_role('MANAGER'))
with check (has_role('ADMIN') or has_role('MANAGER'));

-- -----------------------------
-- WORKCENTER POLICIES
-- -----------------------------
drop policy if exists "read workcenters" on public.workcenters;
create policy "read workcenters"
on public.workcenters
for select
using (auth.uid() is not null);

drop policy if exists "manage workcenters" on public.workcenters;
create policy "manage workcenters"
on public.workcenters
for all
using (has_role('ADMIN') or has_role('MANAGER'))
with check (has_role('ADMIN') or has_role('MANAGER'));

-- -----------------------------
-- TEAMS POLICIES
-- -----------------------------
drop policy if exists "read teams" on public.teams;
create policy "read teams"
on public.teams
for select
using (auth.uid() is not null);

drop policy if exists "manage teams" on public.teams;
create policy "manage teams"
on public.teams
for all
using (has_role('ADMIN') or has_role('MANAGER'))
with check (has_role('ADMIN') or has_role('MANAGER'));

drop policy if exists "manage team members" on public.team_members;
create policy "manage team members"
on public.team_members
for all
using (has_role('ADMIN') or has_role('MANAGER'))
with check (has_role('ADMIN') or has_role('MANAGER'));

-- -----------------------------
-- MAINTENANCE REQUEST POLICIES
-- -----------------------------
drop policy if exists "read requests" on public.maintenance_requests;
create policy "read requests"
on public.maintenance_requests
for select
using (
  has_role('ADMIN')
  or has_role('MANAGER')
  or technician_id = auth.uid()
  or created_by_user_id = auth.uid()
);

drop policy if exists "create requests" on public.maintenance_requests;
create policy "create requests"
on public.maintenance_requests
for insert
with check (
  auth.uid() is not null
  and created_by_user_id = auth.uid()
);

drop policy if exists "update requests" on public.maintenance_requests;
create policy "update requests"
on public.maintenance_requests
for update
using (
  has_role('ADMIN')
  or has_role('MANAGER')
  or technician_id = auth.uid()
)
with check (
  has_role('ADMIN')
  or has_role('MANAGER')
  or technician_id = auth.uid()
);

drop policy if exists "delete requests" on public.maintenance_requests;
create policy "delete requests"
on public.maintenance_requests
for delete
using (has_role('ADMIN') or has_role('MANAGER'));

-- -----------------------------
-- NOTES POLICIES
-- (any involved user can read; any logged-in involved user can add)
-- -----------------------------
drop policy if exists "read notes" on public.request_notes;
create policy "read notes"
on public.request_notes
for select
using (
  exists (
    select 1
    from public.maintenance_requests r
    where r.id = request_id
      and (
        has_role('ADMIN')
        or has_role('MANAGER')
        or r.technician_id = auth.uid()
        or r.created_by_user_id = auth.uid()
      )
  )
);

drop policy if exists "add notes" on public.request_notes;
create policy "add notes"
on public.request_notes
for insert
with check (
  auth.uid() is not null
  and created_by_user_id = auth.uid()
  and exists (
    select 1
    from public.maintenance_requests r
    where r.id = request_id
      and (
        has_role('ADMIN')
        or has_role('MANAGER')
        or r.technician_id = auth.uid()
        or r.created_by_user_id = auth.uid()
      )
  )
);

-- Optional: only ADMIN/MANAGER can delete notes
drop policy if exists "delete notes" on public.request_notes;
create policy "delete notes"
on public.request_notes
for delete
using (has_role('ADMIN') or has_role('MANAGER'));

-- -----------------------------
-- INSTRUCTIONS POLICIES (ADMIN/MANAGER only)
-- -----------------------------
drop policy if exists "manage instructions" on public.request_instructions;
create policy "manage instructions"
on public.request_instructions
for all
using (has_role('ADMIN') or has_role('MANAGER'))
with check (has_role('ADMIN') or has_role('MANAGER'));

-- -----------------------------
-- WORKSHEET POLICIES (TECHNICIAN + ADMIN)
-- -----------------------------
drop policy if exists "worksheet access" on public.request_worksheet_comments;
create policy "worksheet access"
on public.request_worksheet_comments
for all
using (
  has_role('ADMIN')
  or (has_role('TECHNICIAN') and exists (
        select 1 from public.maintenance_requests r
        where r.id = request_id
          and r.technician_id = auth.uid()
      ))
)
with check (
  has_role('ADMIN')
  or (has_role('TECHNICIAN') and exists (
        select 1 from public.maintenance_requests r
        where r.id = request_id
          and r.technician_id = auth.uid()
      ))
);

-- -----------------------------
-- STAGE HISTORY POLICIES (read by involved users, insert by allowed updaters)
-- -----------------------------
drop policy if exists "read stage history" on public.request_stage_history;
create policy "read stage history"
on public.request_stage_history
for select
using (
  exists (
    select 1
    from public.maintenance_requests r
    where r.id = request_id
      and (
        has_role('ADMIN')
        or has_role('MANAGER')
        or r.technician_id = auth.uid()
        or r.created_by_user_id = auth.uid()
      )
  )
);

drop policy if exists "insert stage history" on public.request_stage_history;
create policy "insert stage history"
on public.request_stage_history
for insert
with check (
  auth.uid() is not null
);
