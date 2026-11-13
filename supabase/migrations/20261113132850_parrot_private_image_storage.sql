-- Keep Parrot catalog and brand images private at rest.
-- Public visitors receive short-lived signed URLs from the create-image-urls Edge Function.
-- Existing object keys and database records are preserved; no files are moved or deleted.
UPDATE storage.buckets
SET public = false
WHERE id = 'parrot-images';
