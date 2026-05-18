create table reminders (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references users(id) on delete cascade not null,
  task_id uuid references tasks(id) on delete set null,
  content text not null,
  remind_at timestamptz not null,
  sent boolean default false,
  created_at timestamptz default now()
);

alter table reminders enable row level security;

create policy "Users can only see their own reminders"
  on reminders for all
  using (auth.uid() = user_id);

create index reminders_user_id_idx on reminders(user_id);
create index reminders_remind_at_idx on reminders(remind_at);
create index reminders_sent_idx on reminders(sent);