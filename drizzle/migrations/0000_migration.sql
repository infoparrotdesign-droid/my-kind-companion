create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null default 'Papelaria',
  description text not null default '',
  price numeric not null default 0,
  code text not null default '',
  stock integer not null default 0,
  available boolean not null default true,
  image text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.services (
  id uuid primary key default gen_random_uuid(),
  type text not null unique,
  title text not null,
  description text not null default '',
  image text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

grant select on public.products to anon;
grant select on public.services to anon;
grant select, insert, update, delete on public.products to authenticated;
grant select, insert, update, delete on public.services to authenticated;
grant all on public.products to service_role;
grant all on public.services to service_role;

alter table public.products enable row level security;
alter table public.services enable row level security;

create policy "Products are publicly readable" on public.products for select to anon, authenticated using (true);
create policy "Authenticated users can insert products" on public.products for insert to authenticated with check (true);
create policy "Authenticated users can update products" on public.products for update to authenticated using (true) with check (true);
create policy "Authenticated users can delete products" on public.products for delete to authenticated using (true);

create policy "Services are publicly readable" on public.services for select to anon, authenticated using (true);
create policy "Authenticated users can insert services" on public.services for insert to authenticated with check (true);
create policy "Authenticated users can update services" on public.services for update to authenticated using (true) with check (true);
create policy "Authenticated users can delete services" on public.services for delete to authenticated using (true);