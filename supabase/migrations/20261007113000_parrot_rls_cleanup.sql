-- Clean up duplicate Parrot RLS policies created during early iterations.
drop policy if exists "Admin can delete brand_assets" on public.brand_assets;
drop policy if exists "Admin can insert brand_assets" on public.brand_assets;
drop policy if exists "Admin can update brand_assets" on public.brand_assets;

drop policy if exists "Admin can insert products" on public.products;
drop policy if exists "Admin can update products" on public.products;
drop policy if exists "Admin can delete products" on public.products;
create policy "Admin can insert products" on public.products for insert to authenticated
with check ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');
create policy "Admin can update products" on public.products for update to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com')
with check ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');
create policy "Admin can delete products" on public.products for delete to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

drop policy if exists "Admin can insert services" on public.services;
drop policy if exists "Admin can update services" on public.services;
drop policy if exists "Admin can delete services" on public.services;
create policy "Admin can insert services" on public.services for insert to authenticated
with check ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');
create policy "Admin can update services" on public.services for update to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com')
with check ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');
create policy "Admin can delete services" on public.services for delete to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

drop policy if exists "Admin can insert brand assets" on public.brand_assets;
drop policy if exists "Admin can update brand assets" on public.brand_assets;
drop policy if exists "Admin can delete brand assets" on public.brand_assets;
create policy "Admin can insert brand assets" on public.brand_assets for insert to authenticated
with check ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');
create policy "Admin can update brand assets" on public.brand_assets for update to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com')
with check ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');
create policy "Admin can delete brand assets" on public.brand_assets for delete to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');
