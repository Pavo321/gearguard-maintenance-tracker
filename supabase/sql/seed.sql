-- =========================================================
-- GearGuard - Optional Seed Data
-- =========================================================

insert into public.departments(name) values ('Admin'), ('Production')
on conflict do nothing;

insert into public.locations(name) values ('Plant 1'), ('Office')
on conflict do nothing;

insert into public.equipment_categories(name) values ('Computers'), ('Monitors'), ('Machinery')
on conflict do nothing;

insert into public.teams(name) values ('Internal Maintenance')
on conflict do nothing;
