create extension if not exists vector with schema extensions;

create table memories (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references users(id) on delete cascade not null,
  content text not null,
  type text not null check (type in ('personality', 'habit', 'preference', 'event', 'goal', 'struggle', 'context', 'relationship')),
  importance integer default 5 check (importance between 1 and 10),
  embedding extensions.vector(1536),
  source_date timestamptz default now(),
  last_accessed timestamptz,
  access_count integer default 0,
  expires_at timestamptz,
  created_at timestamptz default now()
);

alter table memories enable row level security;

create policy "Users can only see their own memories"
  on memories for all
  using (auth.uid() = user_id);

create index memories_user_id_idx on memories(user_id);
create index memories_importance_idx on memories(importance desc);