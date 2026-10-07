create table if not exists public.customer_reviews (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null check (char_length(trim(customer_name)) between 2 and 100),
  company text null check (company is null or char_length(trim(company)) between 2 and 120),
  rating integer not null check (rating between 1 and 5),
  comment text not null check (char_length(trim(comment)) between 10 and 1000),
  approved boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.customer_reviews enable row level security;

drop policy if exists "Public can read approved reviews" on public.customer_reviews;
create policy "Public can read approved reviews"
on public.customer_reviews for select
to anon, authenticated
using (approved = true);

drop policy if exists "Public can submit pending reviews" on public.customer_reviews;
create policy "Public can submit pending reviews"
on public.customer_reviews for insert
to anon, authenticated
with check (approved = false);

drop policy if exists "Admin can manage reviews" on public.customer_reviews;
create policy "Admin can manage reviews"
on public.customer_reviews for all
to authenticated
using ((auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com')
with check ((auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

create index if not exists customer_reviews_public_idx
on public.customer_reviews (approved, created_at desc);
