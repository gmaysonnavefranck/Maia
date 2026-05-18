create table users (
  id uuid references auth.users on delete cascade primary key,
  email text unique not null,
  name text,
  timezone text default 'America/New_York',
  checkin_time time default '09:00:00',
  created_at timestamptz default now()
);

alter table users enable row level security;

create policy "Users can only see their own data"
  on users for all
  using (auth.uid() = id);
