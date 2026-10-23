-- Shred Log database setup.
-- Paste this whole file into Supabase → SQL Editor → New query, edit the two emails below, then click Run.

create table if not exists public.members (
  email text primary key,
  name  text not null            -- "Chris" or "Gary": picks the lifter tab when that person signs in
);

-- >>> EDIT THESE TWO LINES: the emails you and Gary will sign in with <<<
insert into public.members (email, name) values
  ('CHRIS_EMAIL_HERE', 'Chris'),
  ('GARY_EMAIL_HERE',  'Gary')
on conflict (email) do update set name = excluded.name;

create table if not exists public.sessions (
  id         text primary key,
  who        text not null,
  day        int  not null,
  date       timestamptz not null,
  finished   boolean not null default false,
  data       jsonb not null,     -- the full session: every set's kg, reps and tick, finisher, bodyweight, notes
  updated_at timestamptz not null default now()
);
create index if not exists sessions_who_day on public.sessions (who, day, date desc);

-- Only signed-in people whose email is on the members list can see or change anything.
create or replace function public.is_member() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.members where lower(email) = lower(auth.jwt() ->> 'email'));
$$;

alter table public.members  enable row level security;
alter table public.sessions enable row level security;

drop policy if exists "members can read the list" on public.members;
create policy "members can read the list" on public.members
  for select to authenticated using (public.is_member());

drop policy if exists "members share all sessions" on public.sessions;
create policy "members share all sessions" on public.sessions
  for all to authenticated using (public.is_member()) with check (public.is_member());
