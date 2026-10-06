-- Additional Parrot catalog defaults: service photography and more products.
-- Existing rows are preserved; only missing service images are filled.
update public.services set image = case type
  when 'logo' then 'https://images.unsplash.com/photo-1626785774573-4b799315345d?auto=format&fit=crop&w=900&h=675&q=80'
  when 'identity' then 'https://images.unsplash.com/photo-1561070791-2526d30994b5?auto=format&fit=crop&w=900&h=675&q=80'
  when 'card' then 'https://images.unsplash.com/photo-1589330694653-ded6df03f754?auto=format&fit=crop&w=900&h=675&q=80'
  when 'flyer' then 'https://images.unsplash.com/photo-1499750310107-5fef28a66643?auto=format&fit=crop&w=900&h=675&q=80'
  when 'invite' then 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?auto=format&fit=crop&w=900&h=675&q=80'
  when 'social' then 'https://images.unsplash.com/photo-1611162617474-5b21e879e113?auto=format&fit=crop&w=900&h=675&q=80'
  when 'menu' then 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=900&h=675&q=80'
  when 'promo' then 'https://images.unsplash.com/photo-1556761175-b413da4baf72?auto=format&fit=crop&w=900&h=675&q=80'
  when 'print' then 'https://images.unsplash.com/photo-1567016432779-094069958ea5?auto=format&fit=crop&w=900&h=675&q=80'
  when 'creative' then 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=900&h=675&q=80'
  when 'tshirt' then 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=900&h=675&q=80'
  when 'mug' then 'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?auto=format&fit=crop&w=900&h=675&q=80'
  when 'stamp' then 'https://images.unsplash.com/photo-1606761568499-6d2451b23c66?auto=format&fit=crop&w=900&h=675&q=80'
  when 'signage' then 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?auto=format&fit=crop&w=900&h=675&q=80'
end
where image is null;

insert into public.services (type,title,description,image) values
('tshirt','Estampagem de camisetas','Personalização de camisetas para marcas, equipas e eventos.','https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=900&h=675&q=80'),
('mug','Personalização de canecas','Canecas personalizadas para presentes, empresas e campanhas.','https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?auto=format&fit=crop&w=900&h=675&q=80'),
('stamp','Produção de carimbos','Carimbos personalizados para empresas e profissionais.','https://images.unsplash.com/photo-1606761568499-6d2451b23c66?auto=format&fit=crop&w=900&h=675&q=80'),
('signage','Placas e sinalização','Soluções de informação, identificação e sinalização visual.','https://images.unsplash.com/photo-1560472354-b33ff0c44a43?auto=format&fit=crop&w=900&h=675&q=80')
on conflict (type) do nothing;

insert into public.products (id,name,category,description,price,code,stock,available,image) values
('starter-paper-a3','Papel A3','Papelaria','Papel A3 para impressão, apresentações e materiais gráficos.',0,'PAP-A3',10,true,'https://images.unsplash.com/photo-1586953208448-b95a79798f07?auto=format&fit=crop&w=900&h=675&q=80'),
('starter-envelope','Envelopes','Papelaria','Envelopes para correspondência e apresentação de documentos.',0,'PAP-ENV',10,true,'https://images.unsplash.com/photo-1572451479139-6a308211d8be?auto=format&fit=crop&w=900&h=675&q=80'),
('starter-notepad','Bloco de notas','Papelaria','Bloco prático para anotações do dia a dia.',0,'PAP-BLO',10,true,'https://images.unsplash.com/photo-1517842645767-c639042777db?auto=format&fit=crop&w=900&h=675&q=80'),
('starter-keyboard-mouse','Kit teclado + rato','Informática','Conjunto básico para estação de trabalho.',0,'INF-KIT-001',5,true,'https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?auto=format&fit=crop&w=900&h=675&q=80'),
('starter-usb','Pen Drive USB','Informática','Armazenamento portátil para documentos e ficheiros.',0,'INF-USB-001',5,true,'https://images.unsplash.com/photo-1614064641938-3bbee52942c7?auto=format&fit=crop&w=900&h=675&q=80'),
('starter-headset','Auscultadores','Informática','Auscultadores para trabalho, chamadas e multimédia.',0,'INF-AUS-001',5,true,'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=900&h=675&q=80'),
('starter-monitor','Monitor','Informática','Monitor para escritório, estudo e trabalho criativo.',0,'INF-MON-001',2,true,'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?auto=format&fit=crop&w=900&h=675&q=80')
on conflict (id) do nothing;
