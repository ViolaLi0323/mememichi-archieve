-- MEMEMICHI ARCHIVE：站点公告表
-- 在 Supabase Dashboard -> SQL Editor 中完整执行一次。

create table if not exists public.site_announcements (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 1 and 120),
  content text not null check (char_length(content) between 1 and 5000),
  is_pinned boolean not null default false,
  is_published boolean not null default false,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.site_announcements enable row level security;

drop policy if exists "Public can read published announcements" on public.site_announcements;
create policy "Public can read published announcements"
on public.site_announcements
for select
to anon, authenticated
using (
  is_published = true
  or exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'admin'
  )
);

drop policy if exists "Admins can insert announcements" on public.site_announcements;
create policy "Admins can insert announcements"
on public.site_announcements
for insert
to authenticated
with check (
  exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'admin'
  )
);

drop policy if exists "Admins can update announcements" on public.site_announcements;
create policy "Admins can update announcements"
on public.site_announcements
for update
to authenticated
using (
  exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'admin'
  )
)
with check (
  exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'admin'
  )
);

drop policy if exists "Admins can delete announcements" on public.site_announcements;
create policy "Admins can delete announcements"
on public.site_announcements
for delete
to authenticated
using (
  exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'admin'
  )
);

grant select on public.site_announcements to anon, authenticated;
grant insert, update, delete on public.site_announcements to authenticated;
