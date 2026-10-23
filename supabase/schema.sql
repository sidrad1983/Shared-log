-- Shred Log database setup.
-- Paste this whole file into Supabase → SQL Editor → New query, then click Run. Safe to run more than once.

create table if not exists public.members (
  email text primary key,
  name  text not null            -- "Chris" or "Gary": picks the lifter tab when that person signs in
);

-- Who can sign in. To add Gary later, run:
--   insert into public.members (email, name) values ('gary@example.com', 'Gary');
insert into public.members (email, name) values
  ('cdardis@svl.co.uk', 'Chris')
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

-- Chris's first workout (Tue 20 Oct 2026, Day 1 · Back), carried over from the claude.ai version of the app.
insert into public.sessions (id, who, day, date, finished, data) values
  ('s1792472330290', 'Chris', 1, '2026-10-20T05:43:35.115Z', true, $json${"bw":"","date":"2026-10-20T05:43:35.115Z","day":1,"ex":{"chest-supported-row":[{"done":true,"kg":"20","reps":"10"},{"done":true,"kg":"22.5","reps":"10"}],"lat-pulldown":[{"done":true,"kg":"42","reps":"12"},{"done":true,"kg":"50","reps":"12"}],"rear-delt-fly":[{"done":true,"kg":"10","reps":"15"},{"done":true,"kg":"8","reps":"15"}],"single-arm-cable-row":[{"done":true,"kg":"60","reps":"12"},{"done":true,"kg":"87.5","reps":"12"}],"straight-arm-pulldown":[{"done":true,"kg":"42.5","reps":"15"},{"done":true,"kg":"","reps":"15"}]},"fin":{"done":true,"mins":"10"},"finished":true,"id":"s1792472330290","notes":"","who":"Chris"}$json$::jsonb)
on conflict (id) do nothing;
