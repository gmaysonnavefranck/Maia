create table moods (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references users(id) on delete cascade not null,
  score integer not null check (score between 1 and 10),
  label text,
  note text,
  created_at timestamptz default now()
);

alter table moods enable row level security;

create policy "Users can only see their own moods"
  on moods for all
  using (auth.uid() = user_id);

create index moods_user_id_idx on moods(user_id);
create index moods_created_at_idx on moods(created_at desc);