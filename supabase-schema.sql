create table if not exists public.participants (
  id uuid primary key default gen_random_uuid(),
  first_name text not null,
  last_name text not null,
  city text not null,
  created_at timestamptz not null default now(),
  constraint participants_identity_unique unique (first_name, last_name, city)
);

create table if not exists public.daily_logs (
  id bigint generated always as identity primary key,
  participant_id uuid not null references public.participants(id) on delete cascade,
  challenge_date date not null,
  workout text not null,
  units integer not null check (units >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint daily_logs_participant_day_unique unique (participant_id, challenge_date)
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_daily_logs_updated_at on public.daily_logs;
create trigger trg_daily_logs_updated_at
before update on public.daily_logs
for each row
execute function public.set_updated_at();

alter table public.participants enable row level security;
alter table public.daily_logs enable row level security;

drop policy if exists participants_select on public.participants;
create policy participants_select on public.participants
for select
to anon
using (true);

drop policy if exists participants_insert on public.participants;
create policy participants_insert on public.participants
for insert
to anon
with check (true);

drop policy if exists daily_logs_select on public.daily_logs;
create policy daily_logs_select on public.daily_logs
for select
to anon
using (true);

drop policy if exists daily_logs_insert on public.daily_logs;
create policy daily_logs_insert on public.daily_logs
for insert
to anon
with check (true);

drop policy if exists daily_logs_update on public.daily_logs;
create policy daily_logs_update on public.daily_logs
for update
to anon
using (true)
with check (true);
