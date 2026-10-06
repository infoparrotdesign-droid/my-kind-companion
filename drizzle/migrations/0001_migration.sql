create policy "Public read parrot images" on storage.objects for select to anon, authenticated using (bucket_id = 'parrot-images');
create policy "Authenticated upload parrot images" on storage.objects for insert to authenticated with check (bucket_id = 'parrot-images');
create policy "Authenticated update parrot images" on storage.objects for update to authenticated using (bucket_id = 'parrot-images') with check (bucket_id = 'parrot-images');
create policy "Authenticated delete parrot images" on storage.objects for delete to authenticated using (bucket_id = 'parrot-images');