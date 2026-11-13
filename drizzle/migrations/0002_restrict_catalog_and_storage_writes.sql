DROP POLICY IF EXISTS "Authenticated users can insert products" ON public.products;
DROP POLICY IF EXISTS "Authenticated users can update products" ON public.products;
DROP POLICY IF EXISTS "Authenticated users can delete products" ON public.products;
CREATE POLICY "Admin can insert products" ON public.products FOR INSERT TO authenticated WITH CHECK (lower((select auth.jwt() ->> 'email')) = 'info.parrotdesign@gmail.com');
CREATE POLICY "Admin can update products" ON public.products FOR UPDATE TO authenticated USING (lower((select auth.jwt() ->> 'email')) = 'info.parrotdesign@gmail.com') WITH CHECK (lower((select auth.jwt() ->> 'email')) = 'info.parrotdesign@gmail.com');
CREATE POLICY "Admin can delete products" ON public.products FOR DELETE TO authenticated USING (lower((select auth.jwt() ->> 'email')) = 'info.parrotdesign@gmail.com');

DROP POLICY IF EXISTS "Authenticated users can insert services" ON public.services;
DROP POLICY IF EXISTS "Authenticated users can update services" ON public.services;
DROP POLICY IF EXISTS "Authenticated users can delete services" ON public.services;
CREATE POLICY "Admin can insert services" ON public.services FOR INSERT TO authenticated WITH CHECK (lower((select auth.jwt() ->> 'email')) = 'info.parrotdesign@gmail.com');
CREATE POLICY "Admin can update services" ON public.services FOR UPDATE TO authenticated USING (lower((select auth.jwt() ->> 'email')) = 'info.parrotdesign@gmail.com') WITH CHECK (lower((select auth.jwt() ->> 'email')) = 'info.parrotdesign@gmail.com');
CREATE POLICY "Admin can delete services" ON public.services FOR DELETE TO authenticated USING (lower((select auth.jwt() ->> 'email')) = 'info.parrotdesign@gmail.com');

DROP POLICY IF EXISTS "Authenticated upload parrot images" ON storage.objects;
CREATE POLICY "Authenticated upload parrot images" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'parrot-images' AND owner_id = (select auth.uid()::text));

DROP POLICY IF EXISTS "Authenticated update parrot images" ON storage.objects;
CREATE POLICY "Authenticated update parrot images" ON storage.objects FOR UPDATE TO authenticated USING (bucket_id = 'parrot-images' AND owner_id = (select auth.uid()::text)) WITH CHECK (bucket_id = 'parrot-images' AND owner_id = (select auth.uid()::text));

DROP POLICY IF EXISTS "Authenticated delete parrot images" ON storage.objects;
CREATE POLICY "Authenticated delete parrot images" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'parrot-images' AND owner_id = (select auth.uid()::text));