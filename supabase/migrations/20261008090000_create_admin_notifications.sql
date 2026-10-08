create table if not exists public.admin_notifications (
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('order','review','system')),
  title text not null check (char_length(trim(title)) between 2 and 180),
  message text not null check (char_length(trim(message)) between 1 and 500),
  reference_id uuid null,
  reference_code text null,
  read_at timestamptz null,
  created_at timestamptz not null default now()
);

alter table public.admin_notifications enable row level security;

create policy "Admin can read notifications"
on public.admin_notifications for select to authenticated
using ((select auth.jwt()->>'email') = 'info.parrotdesign@gmail.com');

create policy "Admin can update notifications"
on public.admin_notifications for update to authenticated
using ((select auth.jwt()->>'email') = 'info.parrotdesign@gmail.com')
with check ((select auth.jwt()->>'email') = 'info.parrotdesign@gmail.com');

create policy "Admin can delete notifications"
on public.admin_notifications for delete to authenticated
using ((select auth.jwt()->>'email') = 'info.parrotdesign@gmail.com');

create index if not exists idx_admin_notifications_created_at on public.admin_notifications(created_at desc);
create index if not exists idx_admin_notifications_unread on public.admin_notifications(read_at, created_at desc);

create schema if not exists private;

create or replace function private.notify_parrot_admin_order()
returns trigger
language plpgsql
security definer
set search_path = public, private
as $$
begin
  insert into public.admin_notifications(kind,title,message,reference_id,reference_code)
  values ('order','Novo pedido recebido','O pedido ' || coalesce(new.order_code,'') || ' foi recebido através do site.',new.id,new.order_code);
  return new;
end;
$$;

revoke all on function private.notify_parrot_admin_order() from public;

drop trigger if exists trg_notify_parrot_admin_order on public.orders;
create trigger trg_notify_parrot_admin_order
after insert on public.orders
for each row execute function private.notify_parrot_admin_order();

create or replace function private.notify_parrot_admin_review()
returns trigger
language plpgsql
security definer
set search_path = public, private
as $$
begin
  insert into public.admin_notifications(kind,title,message,reference_id)
  values ('review','Nova avaliação recebida','A avaliação de ' || trim(new.customer_name) || ' aguarda aprovação.',new.id);
  return new;
end;
$$;

revoke all on function private.notify_parrot_admin_review() from public;

drop trigger if exists trg_notify_parrot_admin_review on public.customer_reviews;
create trigger trg_notify_parrot_admin_review
after insert on public.customer_reviews
for each row execute function private.notify_parrot_admin_review();
