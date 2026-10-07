-- Track when a website order is prepared for WhatsApp
create or replace function public.set_parrot_whatsapp_prepared_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if new.source = 'website' and new.whatsapp_sent_at is null then
    new.whatsapp_sent_at := now();
  end if;
  return new;
end;
$$;

drop trigger if exists trg_orders_whatsapp_prepared on public.orders;
create trigger trg_orders_whatsapp_prepared
before insert on public.orders
for each row
execute function public.set_parrot_whatsapp_prepared_at();

revoke execute on function public.set_parrot_whatsapp_prepared_at() from public;
revoke execute on function public.set_parrot_whatsapp_prepared_at() from anon, authenticated;
