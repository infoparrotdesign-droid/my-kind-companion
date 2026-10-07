-- Optimize Parrot Storage RLS auth checks.
-- Public downloads remain controlled by the bucket's public setting.
-- Admin write/list metadata access remains restricted to the Parrot admin.

drop policy if exists "Admin can upload Parrot images" on storage.objects;
drop policy if exists "Admin can read Parrot image metadata" on storage.objects;
drop policy if exists "Admin can update Parrot images" on storage.objects;
drop policy if exists "Admin can delete Parrot images" on storage.objects;

create policy "Admin can upload Parrot images"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'parrot-images'
  and (select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com'
);

create policy "Admin can read Parrot image metadata"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'parrot-images'
  and (select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com'
);

create policy "Admin can update Parrot images"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'parrot-images'
  and (select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com'
)
with check (
  bucket_id = 'parrot-images'
  and (select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com'
);

create policy "Admin can delete Parrot images"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'parrot-images'
  and (select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com'
);
