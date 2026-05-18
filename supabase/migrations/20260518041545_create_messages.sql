create table messages (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references users(id) on delete cascade not null,
  role text not null check (role in ('user', 'assistant')),
  content text not null,
  created_at timestamptz default now()
);

alter table messages enable row level security;

create policy "Users can only see their own messages"
  on messages for all
  using (auth.uid() = user_id);

create index messages_user_id_idx on messages(user_id);
create index messages_created_at_idx on messages(created_at desc);