create table if not exists public.brand_assets (
  type text primary key check (type in ('main','dark','light','icon')),
  image_url text,
  updated_at timestamptz not null default now()
);

alter table public.brand_assets enable row level security;

drop policy if exists "Public can read brand assets" on public.brand_assets;
create policy "Public can read brand assets"
on public.brand_assets for select
using (true);

drop policy if exists "Admin can insert brand assets" on public.brand_assets;
create policy "Admin can insert brand assets"
on public.brand_assets for insert
to authenticated
with check ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

drop policy if exists "Admin can update brand assets" on public.brand_assets;
create policy "Admin can update brand assets"
on public.brand_assets for update
to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com')
with check ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

drop policy if exists "Admin can delete brand assets" on public.brand_assets;
create policy "Admin can delete brand assets"
on public.brand_assets for delete
to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

insert into public.brand_assets (type, image_url)
values ('main',null),('dark',null),('light',null),('icon',null)
on conflict (type) do nothing;
