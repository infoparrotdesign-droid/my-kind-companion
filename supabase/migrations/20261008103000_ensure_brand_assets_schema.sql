-- Keeps the production brand-assets schema reproducible for Lovable/Supabase deployments.
create table if not exists public.brand_assets (
  type text primary key check (type = any (array['main'::text,'dark'::text,'light'::text,'icon'::text])),
  image_url text,
  updated_at timestamptz not null default now()
);

alter table public.brand_assets enable row level security;

drop policy if exists "Public can read brand assets" on public.brand_assets;
create policy "Public can read brand assets"
on public.brand_assets for select
to public
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

grant select on public.brand_assets to anon, authenticated;
grant insert, update, delete on public.brand_assets to authenticated;

alter table public.brand_assets alter column updated_at set default now();

notify pgrst, 'reload schema';
