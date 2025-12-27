-- =========================================================
-- GearGuard - Schema (Enums + Tables + Indexes + Constraints)
-- =========================================================

-- -----------------------------
-- ENUMS
-- -----------------------------
do $$ begin
  create type public.user_role as enum ('ADMIN','MANAGER','TECHNICIAN','EMPLOYEE');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.used_by_type as enum ('EMPLOYEE','DEPARTMENT');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.maintenance_for as enum ('EQUIPMENT','WORKCENTER');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.maintenance_type as enum ('CORRECTIVE','PREVENTIVE');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.request_stage as enum ('NEW_REQUEST','IN_PROGRESS','REPAIRED','SCRAP');
exception when duplicate_object then null; end $$;

-- -----------------------------
-- PROFILES (app users linked to Supabase Auth)
-- -----------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  email text unique,
  role public.user_role not null default 'EMPLOYEE',
  company text not null default 'My Company',
  created_at timestamptz not null default now()
);

-- -----------------------------
-- MASTER DATA
-- -----------------------------
create table if not exists public.departments (
  id bigserial primary key,
  name text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.locations (
  id bigserial primary key,
  name text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.equipment_categories (
  id bigserial primary key,
  name text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.teams (
  id bigserial primary key,
  name text not null unique,
  company text not null default 'My Company',
  created_at timestamptz not null default now()
);

create table if not exists public.team_members (
  team_id bigint not null references public.teams(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  added_at timestamptz not null default now(),
  primary key (team_id, user_id)
);

-- -----------------------------
-- WORK CENTERS
-- -----------------------------
create table if not exists public.workcenters (
  id bigserial primary key,
  name text not null,
  code text,
  tag text,
  alternative_workcenters text,
  cost_per_hour numeric(10,2),
  capacity numeric(10,2),
  time_efficiency numeric(6,2),
  oee_target numeric(6,2),
  company text not null default 'My Company',
  created_at timestamptz not null default now()
);

create index if not exists idx_workcenters_name on public.workcenters (name);

-- -----------------------------
-- EQUIPMENT
-- -----------------------------
create table if not exists public.equipment (
  id bigserial primary key,

  name text not null,
  serial_number text,

  category_id bigint references public.equipment_categories(id) on delete set null,

  used_by_type public.used_by_type not null default 'EMPLOYEE',
  used_by_user_id uuid references public.profiles(id) on delete set null,
  used_by_department_id bigint references public.departments(id) on delete set null,

  maintenance_team_id bigint references public.teams(id) on delete set null,
  default_technician_id uuid references public.profiles(id) on delete set null,

  location_id bigint references public.locations(id) on delete set null,

  assigned_date date,
  scrap_date date,
  purchase_date date,
  warranty_end_date date,

  description text,

  company text not null default 'My Company',
  created_at timestamptz not null default now()
);

create index if not exists idx_equipment_name on public.equipment (name);
create index if not exists idx_equipment_serial on public.equipment (serial_number);

do $$ begin
  alter table public.equipment
    add constraint equipment_used_by_check
    check (
      (used_by_type = 'EMPLOYEE' and used_by_user_id is not null and used_by_department_id is null)
      or
      (used_by_type = 'DEPARTMENT' and used_by_department_id is not null and used_by_user_id is null)
    );
exception when duplicate_object then null; end $$;

-- -----------------------------
-- MAINTENANCE REQUESTS
-- -----------------------------
create table if not exists public.maintenance_requests (
  id bigserial primary key,

  subject text not null,

  created_by_user_id uuid not null references public.profiles(id) on delete restrict,

  maintenance_for public.maintenance_for not null default 'EQUIPMENT',
  equipment_id bigint references public.equipment(id) on delete set null,
  workcenter_id bigint references public.workcenters(id) on delete set null,

  category_id bigint references public.equipment_categories(id) on delete set null,

  request_date date not null default (now()::date),
  maintenance_type public.maintenance_type not null default 'CORRECTIVE',

  team_id bigint references public.teams(id) on delete set null,
  technician_id uuid references public.profiles(id) on delete set null,

  scheduled_at timestamptz,
  duration_minutes integer not null default 0,

  priority smallint not null default 2, -- 1 low 2 medium 3 high
  stage public.request_stage not null default 'NEW_REQUEST',
  blocked boolean not null default false,

  company text not null default 'My Company',
  created_at timestamptz not null default now()
);

create index if not exists idx_requests_stage on public.maintenance_requests (stage);
create index if not exists idx_requests_sched on public.maintenance_requests (scheduled_at);
create index if not exists idx_requests_subject on public.maintenance_requests (subject);

do $$ begin
  alter table public.maintenance_requests
    add constraint request_target_check
    check (
      (maintenance_for = 'EQUIPMENT' and equipment_id is not null and workcenter_id is null)
      or
      (maintenance_for = 'WORKCENTER' and workcenter_id is not null and equipment_id is null)
    );
exception when duplicate_object then null; end $$;

do $$ begin
  alter table public.maintenance_requests
    add constraint request_priority_check
    check (priority between 1 and 3);
exception when duplicate_object then null; end $$;

-- -----------------------------
-- REQUEST DETAIL TABLES
-- -----------------------------
create table if not exists public.request_notes (
  id bigserial primary key,
  request_id bigint not null references public.maintenance_requests(id) on delete cascade,
  note text not null,
  created_by_user_id uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.request_instructions (
  id bigserial primary key,
  request_id bigint not null references public.maintenance_requests(id) on delete cascade,
  instruction text not null,
  created_by_user_id uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.request_worksheet_comments (
  id bigserial primary key,
  request_id bigint not null references public.maintenance_requests(id) on delete cascade,
  comment text not null,
  created_by_user_id uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create index if not exists idx_notes_request on public.request_notes (request_id);
create index if not exists idx_instructions_request on public.request_instructions (request_id);
create index if not exists idx_worksheet_request on public.request_worksheet_comments (request_id);

-- Optional audit table for stage changes
create table if not exists public.request_stage_history (
  id bigserial primary key,
  request_id bigint not null references public.maintenance_requests(id) on delete cascade,
  from_stage public.request_stage,
  to_stage public.request_stage not null,
  changed_by_user_id uuid references public.profiles(id) on delete set null,
  changed_at timestamptz not null default now()
);

create index if not exists idx_stage_hist_req on public.request_stage_history (request_id);
