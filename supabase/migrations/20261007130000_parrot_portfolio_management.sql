create extension if not exists pgcrypto;

create table if not exists public.portfolio_projects (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(trim(title)) between 2 and 180),
  category text not null default 'Geral' check (char_length(trim(category)) between 2 and 80),
  description text not null default '',
  image text,
  client text,
  project_year integer check (project_year is null or project_year between 2000 and 2200),
  featured boolean not null default false,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.portfolio_projects enable row level security;

drop policy if exists "Public can read portfolio projects" on public.portfolio_projects;
create policy "Public can read portfolio projects"
on public.portfolio_projects
for select
to public
using (true);

drop policy if exists "Admin can create portfolio projects" on public.portfolio_projects;
create policy "Admin can create portfolio projects"
on public.portfolio_projects
for insert
to authenticated
with check ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

drop policy if exists "Admin can read portfolio projects" on public.portfolio_projects;
create policy "Admin can read portfolio projects"
on public.portfolio_projects
for select
to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

drop policy if exists "Admin can update portfolio projects" on public.portfolio_projects;
create policy "Admin can update portfolio projects"
on public.portfolio_projects
for update
to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com')
with check ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

drop policy if exists "Admin can delete portfolio projects" on public.portfolio_projects;
create policy "Admin can delete portfolio projects"
on public.portfolio_projects
for delete
to authenticated
using ((select auth.jwt() ->> 'email') = 'info.parrotdesign@gmail.com');

grant select on public.portfolio_projects to anon, authenticated;
grant insert, update, delete on public.portfolio_projects to authenticated;

create index if not exists idx_portfolio_projects_sort_order on public.portfolio_projects (sort_order, created_at desc);

insert into public.portfolio_projects (title, category, description, sort_order)
values
  ('Identidade de marca', 'Branding', 'Projetos de identidade visual pensados para reforçar reconhecimento e consistência.', 10),
  ('Campanha promocional', 'Publicidade', 'Peças de comunicação para campanhas, produtos e ofertas.', 20),
  ('Menu profissional', 'Menus', 'Menus organizados e preparados para apresentação e impressão.', 30),
  ('Comunicação digital', 'Redes sociais', 'Artes digitais alinhadas com a identidade de cada marca.', 40),
  ('Material corporativo', 'Corporativo', 'Materiais gráficos para uma comunicação empresarial profissional.', 50),
  ('Design para eventos', 'Eventos', 'Peças visuais personalizadas para eventos e ocasiões especiais.', 60)
on conflict do nothing;
