-- Parrot order status audit trail
create schema if not exists private;

create table if not exists public.order_status_history (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  from_status text,
  to_status text not null check (to_status in ('new','in_review','quote_sent','awaiting_payment','in_production','ready','delivered','cancelled')),
  changed_by text,
  changed_at timestamptz not null default now()
);

create index if not exists idx_order_status_history_order_id_changed_at
  on public.order_status_history(order_id, changed_at desc);

alter table public.order_status_history enable row level security;

drop policy if exists "Admin can read Parrot order status history" on public.order_status_history;
create policy "Admin can read Parrot order status history"
on public.order_status_history for select
to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

revoke all privileges on table public.order_status_history from anon;
revoke all privileges on table public.order_status_history from authenticated;
grant select on table public.order_status_history to authenticated;

create or replace function private.record_parrot_order_status_change()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, auth
as $$
declare
  v_changed_by text;
begin
  v_changed_by := coalesce(
    (select auth.jwt() ->> 'email'),
    case when tg_op = 'INSERT' then 'website' else 'admin' end
  );

  if tg_op = 'INSERT' then
    insert into public.order_status_history(order_id, from_status, to_status, changed_by)
    values (new.id, null, new.status, v_changed_by);
    return new;
  end if;

  if old.status is distinct from new.status then
    insert into public.order_status_history(order_id, from_status, to_status, changed_by)
    values (new.id, old.status, new.status, v_changed_by);
  end if;

  return new;
end;
$$;

revoke execute on function private.record_parrot_order_status_change() from public;
revoke execute on function private.record_parrot_order_status_change() from anon, authenticated;

drop trigger if exists trg_record_parrot_order_status_change on public.orders;
create trigger trg_record_parrot_order_status_change
after insert or update of status on public.orders
for each row
execute function private.record_parrot_order_status_change();
