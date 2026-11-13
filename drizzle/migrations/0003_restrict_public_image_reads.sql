DROP POLICY IF EXISTS "Public read parrot images" ON storage.objects;
CREATE POLICY "Owners can read parrot images"
ON storage.objects
FOR SELECT
TO authenticated
USING (
  bucket_id = 'parrot-images'
  AND owner_id = (SELECT auth.uid())::text
);