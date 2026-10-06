-- Allow larger original Parrot logo files and explicit common image formats.
update storage.buckets
set file_size_limit = 20971520,
    allowed_mime_types = array['image/png','image/jpeg','image/webp','image/gif','image/svg+xml']
where id = 'parrot-images';
