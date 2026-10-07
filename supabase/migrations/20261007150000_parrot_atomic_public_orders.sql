-- Parrot atomic public order creation
create or replace function public.create_public_order(
  p_order jsonb,
  p_items jsonb default '[]'::jsonb,
  p_service jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_order_id uuid := gen_random_uuid();
  v_order_code text;
  v_order_type text;
  v_customer_name text;
  v_customer_phone text;
  v_customer_email text;
  v_delivery_address text;
  v_delivery_reference text;
  v_notes text;
  v_service_type text;
  v_service_title text;
  v_service_description text;
  v_service_details jsonb;
  v_requested_details jsonb;
  v_total numeric(12,2) := 0;
  v_invalid_item_count integer := 0;
begin
  if p_order is null or jsonb_typeof(p_order) <> 'object' then
    raise exception using errcode = '22023', message = 'Dados do pedido inválidos.';
  end if;

  if p_items is null or jsonb_typeof(p_items) <> 'array' then
    raise exception using errcode = '22023', message = 'Itens do pedido inválidos.';
  end if;

  if p_service is null or jsonb_typeof(p_service) <> 'object' then
    raise exception using errcode = '22023', message = 'Dados do serviço inválidos.';
  end if;

  if octet_length(p_order::text) > 16000
     or octet_length(p_items::text) > 16000
     or octet_length(p_service::text) > 16000 then
    raise exception using errcode = '22023', message = 'O pedido excede o tamanho permitido.';
  end if;

  v_order_type := trim(coalesce(p_order ->> 'order_type', ''));
  v_customer_name := trim(coalesce(p_order ->> 'customer_name', ''));
  v_customer_phone := trim(coalesce(p_order ->> 'customer_phone', ''));
  v_customer_email := nullif(trim(coalesce(p_order ->> 'customer_email', '')), '');
  v_delivery_address := trim(coalesce(p_order ->> 'delivery_address', ''));
  v_delivery_reference := nullif(trim(coalesce(p_order ->> 'delivery_reference', '')), '');
  v_notes := nullif(trim(coalesce(p_order ->> 'notes', '')), '');

  if v_order_type not in ('product', 'service') then
    raise exception using errcode = '22023', message = 'Tipo de pedido inválido.';
  end if;

  if char_length(v_customer_name) < 2 or char_length(v_customer_name) > 150 then
    raise exception using errcode = '22023', message = 'Nome do cliente inválido.';
  end if;

  if char_length(v_customer_phone) < 5 or char_length(v_customer_phone) > 30 then
    raise exception using errcode = '22023', message = 'Telefone do cliente inválido.';
  end if;

  if char_length(v_delivery_address) < 3 or char_length(v_delivery_address) > 250 then
    raise exception using errcode = '22023', message = 'Endereço inválido.';
  end if;

  if v_customer_email is not null and char_length(v_customer_email) > 254 then
    raise exception using errcode = '22023', message = 'Email do cliente inválido.';
  end if;

  if v_notes is not null and char_length(v_notes) > 3000 then
    raise exception using errcode = '22023', message = 'As observações excedem o limite permitido.';
  end if;

  v_order_code :=
    'PRT-' ||
    to_char((now() at time zone 'Africa/Maputo')::date, 'YYYYMMDD') ||
    '-' ||
    upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 6));

  if v_order_type = 'product' then
    if jsonb_array_length(p_items) = 0 then
      raise exception using errcode = '22023', message = 'Adicione pelo menos um produto ao pedido.';
    end if;

    if exists (
      select 1
      from jsonb_to_recordset(p_items) as x(product_id text, quantity integer)
      where nullif(trim(coalesce(x.product_id, '')), '') is null
         or x.quantity is null
         or x.quantity <= 0
         or x.quantity > 100
    ) then
      raise exception using errcode = '22023', message = 'Um ou mais itens do pedido são inválidos.';
    end if;

    perform 1
    from public.products p
    where p.id in (
      select trim(x.product_id)
      from jsonb_to_recordset(p_items) as x(product_id text, quantity integer)
    )
    for share;

    with requested as (
      select trim(x.product_id) as product_id, sum(x.quantity)::integer as quantity
      from jsonb_to_recordset(p_items) as x(product_id text, quantity integer)
      group by trim(x.product_id)
    )
    select
      count(*) filter (
        where p.id is null
           or p.available is false
           or r.quantity > p.stock
      )::integer,
      coalesce(sum(p.price * r.quantity), 0)::numeric(12,2)
    into v_invalid_item_count, v_total
    from requested r
    left join public.products p on p.id = r.product_id;

    if v_invalid_item_count > 0 then
      raise exception using errcode = '22023', message = 'Um ou mais produtos estão indisponíveis ou sem stock suficiente.';
    end if;

    insert into public.orders (
      id, order_code, customer_id, order_type, status, total,
      customer_name, customer_phone, customer_email,
      delivery_address, delivery_reference,
      service_type, service_title, service_description,
      notes, source
    )
    values (
      v_order_id, v_order_code, null, 'product', 'new', v_total,
      v_customer_name, v_customer_phone, v_customer_email,
      v_delivery_address, v_delivery_reference,
      null, null, null,
      v_notes, 'website'
    );

    with requested as (
      select trim(x.product_id) as product_id, sum(x.quantity)::integer as quantity
      from jsonb_to_recordset(p_items) as x(product_id text, quantity integer)
      group by trim(x.product_id)
    )
    insert into public.order_items (
      order_id, product_id, product_name, product_code,
      quantity, unit_price, subtotal
    )
    select
      v_order_id, p.id, p.name, nullif(p.code, ''),
      r.quantity, p.price, round(p.price * r.quantity, 2)
    from requested r
    join public.products p on p.id = r.product_id;

  else
    if jsonb_array_length(p_items) > 0 then
      raise exception using errcode = '22023', message = 'Um pedido de serviço não pode conter produtos do carrinho.';
    end if;

    v_service_type := trim(coalesce(p_service ->> 'service_type', ''));
    v_service_details := coalesce(p_service -> 'service_details', '{}'::jsonb);

    if v_service_type = '' then
      raise exception using errcode = '22023', message = 'Serviço solicitado inválido.';
    end if;

    if jsonb_typeof(v_service_details) <> 'object' then
      raise exception using errcode = '22023', message = 'Detalhes do serviço inválidos.';
    end if;

    select s.title, s.description
    into v_service_title, v_service_description
    from public.services s
    where s.type = v_service_type;

    if not found then
      raise exception using errcode = '22023', message = 'O serviço solicitado não está disponível.';
    end if;

    v_requested_details := jsonb_build_object(
      'customer',
      jsonb_build_object(
        'name', v_customer_name,
        'phone', v_customer_phone,
        'email', v_customer_email,
        'address', v_delivery_address,
        'reference', v_delivery_reference
      ),
      'service', v_service_details
    );

    insert into public.orders (
      id, order_code, customer_id, order_type, status, total,
      customer_name, customer_phone, customer_email,
      delivery_address, delivery_reference,
      service_type, service_title, service_description,
      notes, source
    )
    values (
      v_order_id, v_order_code, null, 'service', 'new', 0,
      v_customer_name, v_customer_phone, v_customer_email,
      v_delivery_address, v_delivery_reference,
      v_service_type, v_service_title, v_service_description,
      v_notes, 'website'
    );

    insert into public.service_requests (
      order_id, service_type, service_title, service_description, requested_details
    )
    values (
      v_order_id, v_service_type, v_service_title, v_service_description, v_requested_details
    );
  end if;

  return jsonb_build_object(
    'order_id', v_order_id,
    'order_code', v_order_code,
    'total', v_total
  );
end;
$$;

revoke execute on function public.create_public_order(jsonb, jsonb, jsonb) from public;
revoke execute on function public.create_public_order(jsonb, jsonb, jsonb) from anon, authenticated;
grant execute on function public.create_public_order(jsonb, jsonb, jsonb) to anon, authenticated;
