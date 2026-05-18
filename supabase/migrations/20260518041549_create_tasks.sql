create table tasks (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references users(id) on delete cascade not null,
  project_id uuid references projects(id) on delete set null,
  title text not null,
  description text,
  status text default 'todo' check (status in ('todo', 'in_progress', 'done')),
  priority text default 'medium' check (priority in ('low', 'medium', 'high')),
  due_date timestamptz,
  completed_at timestamptz,
  position integer default 0,
  source text default 'manual' check (source in ('manual', 'chat')),
  created_at timestamptz default now()
);

alter table tasks enable row level security;

create policy "Users can only see their own tasks"
  on tasks for all
  using (auth.uid() = user_id);

create index tasks_user_id_idx on tasks(user_id);
create index tasks_project_id_idx on tasks(project_id);
create index tasks_due_date_idx on tasks(due_date);
create index tasks_status_idx on tasks(status);