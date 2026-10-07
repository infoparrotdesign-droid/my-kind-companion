-- Parrot order management
create extension if not exists pgcrypto;

create table if not exists public.customers (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) between 2 and 150),
  phone text not null check (char_length(trim(phone)) between 5 and 30),
  email text,
  address text not null check (char_length(trim(address)) between 3 and 250),
  reference text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_code text not null unique,
  customer_id uuid references public.customers(id) on delete set null,
  order_type text not null check (order_type in ('product','service')),
  status text not null default 'new' check (status in ('new','in_review','quote_sent','awaiting_payment','in_production','ready','delivered','cancelled')),
  total numeric(12,2) not null default 0 check (total >= 0),
  customer_name text,
  customer_phone text,
  customer_email text,
  delivery_address text,
  delivery_reference text,
  service_type text,
  service_title text,
  service_description text,
  notes text,
  source text not null default 'website',
  whatsapp_sent_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id text references public.products(id) on delete set null,
  product_name text not null,
  product_code text,
  quantity integer not null check (quantity > 0),
  unit_price numeric(12,2) not null check (unit_price >= 0),
  subtotal numeric(12,2) not null check (subtotal >= 0),
  created_at timestamptz not null default now()
);

create table if not exists public.service_requests (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null unique references public.orders(id) on delete cascade,
  service_type text references public.services(type) on delete set null,
  service_title text not null,
  service_description text,
  requested_details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_orders_customer_id on public.orders(customer_id);
create index if not exists idx_orders_status on public.orders(status);
create index if not exists idx_orders_created_at on public.orders(created_at desc);
create index if not exists idx_order_items_order_id on public.order_items(order_id);
create index if not exists idx_order_items_product_id on public.order_items(product_id);
create index if not exists idx_service_requests_order_id on public.service_requests(order_id);
create index if not exists idx_service_requests_service_type on public.service_requests(service_type);

alter table public.customers enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.service_requests enable row level security;

drop policy if exists "Admin can create Parrot customers" on public.customers;
create policy "Admin can create Parrot customers"
on public.customers for insert
to authenticated
with check ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

drop policy if exists "Admin can read Parrot customers" on public.customers;
create policy "Admin can read Parrot customers"
on public.customers for select
to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

drop policy if exists "Admin can update Parrot customers" on public.customers;
create policy "Admin can update Parrot customers"
on public.customers for update
to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com')
with check ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');


drop policy if exists "Admin can delete Parrot customers" on public.customers;
create policy "Admin can delete Parrot customers"
on public.customers for delete
to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

drop policy if exists "Public can create Parrot orders" on public.orders;
create policy "Public can create Parrot orders"
on public.orders for insert
to anon, authenticated
with check (
  order_type in ('product','service')
  and status = 'new'
  and total >= 0
  and source = 'website'
  and customer_name is not null
  and char_length(trim(customer_name)) between 2 and 150
  and customer_phone is not null
  and char_length(trim(customer_phone)) between 5 and 30
  and delivery_address is not null
  and char_length(trim(delivery_address)) between 3 and 250
);

drop policy if exists "Admin can read Parrot orders" on public.orders;
create policy "Admin can read Parrot orders"
on public.orders for select
to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

drop policy if exists "Admin can update Parrot orders" on public.orders;
create policy "Admin can update Parrot orders"
on public.orders for update
to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com')
with check ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

drop policy if exists "Admin can delete Parrot orders" on public.orders;
create policy "Admin can delete Parrot orders"
on public.orders for delete
to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

drop policy if exists "Public can create Parrot order items" on public.order_items;
create policy "Public can create Parrot order items"
on public.order_items for insert
to anon, authenticated
with check (quantity > 0 and unit_price >= 0 and subtotal >= 0);

drop policy if exists "Admin can read Parrot order items" on public.order_items;
create policy "Admin can read Parrot order items"
on public.order_items for select
to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

drop policy if exists "Admin can update Parrot order items" on public.order_items;
create policy "Admin can update Parrot order items"
on public.order_items for update
to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com')
with check ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

drop policy if exists "Admin can delete Parrot order items" on public.order_items;
create policy "Admin can delete Parrot order items"
on public.order_items for delete
to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

drop policy if exists "Public can create Parrot service requests" on public.service_requests;
create policy "Public can create Parrot service requests"
on public.service_requests for insert
to anon, authenticated
with check (char_length(trim(service_title)) between 2 and 200);

drop policy if exists "Admin can read Parrot service requests" on public.service_requests;
create policy "Admin can read Parrot service requests"
on public.service_requests for select
to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

drop policy if exists "Admin can update Parrot service requests" on public.service_requests;
create policy "Admin can update Parrot service requests"
on public.service_requests for update
to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com')
with check ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

drop policy if exists "Admin can delete Parrot service requests" on public.service_requests;
create policy "Admin can delete Parrot service requests"
on public.service_requests for delete
to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

revoke all privileges on table public.customers, public.orders, public.order_items, public.service_requests from anon;
revoke all privileges on table public.customers, public.orders, public.order_items, public.service_requests from authenticated;
grant insert on table public.orders, public.order_items, public.service_requests to anon;
grant select, insert, update, delete on table public.customers, public.orders, public.order_items, public.service_requests to authenticated;
