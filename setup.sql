-- y.aoi database setup. Paste all of this into Supabase > SQL Editor and press Run.

-- Ideas: one row per slip
create table public.ideas (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  num         integer not null,
  text        text not null default '',
  sketch      text,
  kind        text not null default 'text',
  todo        boolean not null default false,
  created_at  timestamptz not null default now(),
  printed_at  timestamptz
);
create index ideas_user_created on public.ideas (user_id, created_at desc);

alter table public.ideas enable row level security;
create policy "ideas: read own"   on public.ideas for select to authenticated using (auth.uid() = user_id);
create policy "ideas: add own"    on public.ideas for insert to authenticated with check (auth.uid() = user_id);
create policy "ideas: edit own"   on public.ideas for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "ideas: delete own" on public.ideas for delete to authenticated using (auth.uid() = user_id);

-- Settings: your print day
create table public.settings (
  user_id    uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  print_day  smallint not null default 0 check (print_day between 0 and 6)
);
alter table public.settings enable row level security;
create policy "settings: read own" on public.settings for select to authenticated using (auth.uid() = user_id);
create policy "settings: add own"  on public.settings for insert to authenticated with check (auth.uid() = user_id);
create policy "settings: edit own" on public.settings for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Live updates: phone captures appear on the laptop without refreshing
alter publication supabase_realtime add table public.ideas;
