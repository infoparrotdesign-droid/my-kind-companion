alter table public.orders
  add column quoted_total numeric(12,2),
  add column amount_paid numeric(12,2) not null default 0,
  add column payment_status text not null default 'not_set',
  add column payment_method text,
  add column payment_notes text,
  add column financial_updated_at timestamptz not null default now();

alter table public.orders
  add constraint orders_quoted_total_nonnegative
    check (quoted_total is null or quoted_total >= 0),
  add constraint orders_amount_paid_nonnegative
    check (amount_paid >= 0),
  add constraint orders_payment_status_valid
    check (payment_status in ('not_set', 'pending', 'partial', 'paid')),
  add constraint orders_amount_paid_not_above_total
    check (
      amount_paid <= case
        when order_type = 'service' then coalesce(quoted_total, 0)
        else total
      end
    );

create or replace function private.sync_parrot_order_financial_status()
returns trigger
language plpgsql
security invoker
set search_path = pg_catalog
as $$
declare
  effective_total numeric(12,2);
begin
  if new.amount_paid is null then
    new.amount_paid := 0;
  end if;

  if new.order_type = 'service' then
    effective_total := coalesce(new.quoted_total, 0);
  else
    effective_total := coalesce(new.total, 0);
  end if;

  if new.amount_paid > effective_total then
    raise exception 'O valor recebido não pode exceder o total do pedido.';
  end if;

  if effective_total <= 0 then
    new.payment_status := 'not_set';
  elsif new.amount_paid = 0 then
    new.payment_status := 'pending';
  elsif new.amount_paid < effective_total then
    new.payment_status := 'partial';
  else
    new.payment_status := 'paid';
  end if;

  new.financial_updated_at := now();
  return new;
end;
$$;

create trigger trg_sync_parrot_order_financial_status
before insert or update of quoted_total, amount_paid, payment_status, payment_method, payment_notes
on public.orders
for each row
execute function private.sync_parrot_order_financial_status();

revoke all on function private.sync_parrot_order_financial_status() from public, anon, authenticated;