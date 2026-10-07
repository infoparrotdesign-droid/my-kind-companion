-- Parrot customer interaction history
create table if not exists public.customer_interactions (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.customers(id) on delete cascade,
  interaction_type text not null check (interaction_type in ('note','whatsapp','call','email','meeting','follow_up','quote')),
  note text not null check (char_length(trim(note)) between 1 and 2000),
  happened_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index if not exists idx_customer_interactions_customer_happened_at
  on public.customer_interactions(customer_id, happened_at desc);

alter table public.customer_interactions enable row level security;

drop policy if exists "Admin can read Parrot customer interactions" on public.customer_interactions;
create policy "Admin can read Parrot customer interactions"
on public.customer_interactions for select
to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

drop policy if exists "Admin can create Parrot customer interactions" on public.customer_interactions;
create policy "Admin can create Parrot customer interactions"
on public.customer_interactions for insert
to authenticated
with check ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

drop policy if exists "Admin can update Parrot customer interactions" on public.customer_interactions;
create policy "Admin can update Parrot customer interactions"
on public.customer_interactions for update
to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com')
with check ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

drop policy if exists "Admin can delete Parrot customer interactions" on public.customer_interactions;
create policy "Admin can delete Parrot customer interactions"
on public.customer_interactions for delete
to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

revoke all privileges on table public.customer_interactions from anon, authenticated;
grant select, insert, update, delete on table public.customer_interactions to authenticated;
