-- Automatically generate unique catalog codes for Parrot products and services.
-- Existing product codes are preserved; only missing codes are filled.

CREATE SEQUENCE IF NOT EXISTS public.product_catalog_code_seq START WITH 1;
CREATE SEQUENCE IF NOT EXISTS public.service_catalog_code_seq START WITH 1;

ALTER TABLE public.services ADD COLUMN IF NOT EXISTS code text;

WITH missing AS (
  SELECT id, row_number() OVER (ORDER BY created_at, id) AS rn
  FROM public.products
  WHERE code IS NULL OR btrim(code) = ''
)
UPDATE public.products p
SET code = 'PRD-' || CASE WHEN m.rn < 10000 THEN lpad(m.rn::text, 4, '0') ELSE m.rn::text END,
    updated_at = now()
FROM missing m
WHERE p.id = m.id;

WITH missing AS (
  SELECT type, row_number() OVER (ORDER BY created_at, type) AS rn
  FROM public.services
  WHERE code IS NULL OR btrim(code) = ''
)
UPDATE public.services s
SET code = 'SRV-' || CASE WHEN m.rn < 10000 THEN lpad(m.rn::text, 4, '0') ELSE m.rn::text END,
    updated_at = now()
FROM missing m
WHERE s.type = m.type;

ALTER TABLE public.services ALTER COLUMN code SET NOT NULL;

SELECT setval(
  'public.product_catalog_code_seq',
  GREATEST(COALESCE(MAX(split_part(code, '-', 2)::bigint), 1), 1),
  COALESCE(MAX(split_part(code, '-', 2)::bigint), 0) > 0
)
FROM public.products
WHERE code ~ '^PRD-[0-9]+$';

SELECT setval(
  'public.service_catalog_code_seq',
  GREATEST(COALESCE(MAX(split_part(code, '-', 2)::bigint), 1), 1),
  COALESCE(MAX(split_part(code, '-', 2)::bigint), 0) > 0
)
FROM public.services
WHERE code ~ '^SRV-[0-9]+$';

CREATE UNIQUE INDEX IF NOT EXISTS products_catalog_code_unique
  ON public.products (upper(btrim(code)))
  WHERE code IS NOT NULL AND btrim(code) <> '';

CREATE UNIQUE INDEX IF NOT EXISTS services_catalog_code_unique
  ON public.services (upper(btrim(code)));

CREATE OR REPLACE FUNCTION public.assign_product_catalog_code()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  next_number bigint;
  candidate text;
BEGIN
  IF NEW.code IS NULL OR btrim(NEW.code) = '' THEN
    LOOP
      next_number := nextval('public.product_catalog_code_seq');
      candidate := 'PRD-' || CASE WHEN next_number < 10000 THEN lpad(next_number::text, 4, '0') ELSE next_number::text END;
      EXIT WHEN NOT EXISTS (
        SELECT 1 FROM public.products p WHERE upper(btrim(p.code)) = candidate
      );
    END LOOP;
    NEW.code := candidate;
  ELSE
    NEW.code := upper(btrim(NEW.code));
  END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.assign_service_catalog_code()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  next_number bigint;
  candidate text;
BEGIN
  IF NEW.code IS NULL OR btrim(NEW.code) = '' THEN
    LOOP
      next_number := nextval('public.service_catalog_code_seq');
      candidate := 'SRV-' || CASE WHEN next_number < 10000 THEN lpad(next_number::text, 4, '0') ELSE next_number::text END;
      EXIT WHEN NOT EXISTS (
        SELECT 1 FROM public.services s WHERE upper(btrim(s.code)) = candidate
      );
    END LOOP;
    NEW.code := candidate;
  ELSE
    NEW.code := upper(btrim(NEW.code));
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS products_assign_catalog_code ON public.products;
CREATE TRIGGER products_assign_catalog_code
BEFORE INSERT OR UPDATE OF code ON public.products
FOR EACH ROW EXECUTE FUNCTION public.assign_product_catalog_code();

DROP TRIGGER IF EXISTS services_assign_catalog_code ON public.services;
CREATE TRIGGER services_assign_catalog_code
BEFORE INSERT OR UPDATE OF code ON public.services
FOR EACH ROW EXECUTE FUNCTION public.assign_service_catalog_code();

GRANT USAGE, SELECT ON SEQUENCE public.product_catalog_code_seq TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.service_catalog_code_seq TO authenticated;
