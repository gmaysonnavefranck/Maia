create table projects (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references users(id) on delete cascade not null,
  title text not null,
  description text,
  color text default '#534ab7',
  status text default 'active' check (status in ('active', 'completed', 'archived')),
  created_at timestamptz default now()
);

alter table projects enable row level security;

create policy "Users can only see their own projects"
  on projects for all
  using (auth.uid() = user_id);

create index projects_user_id_idx on projects(user_id);