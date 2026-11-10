-- Jalankan satu kali di Supabase SQL Editor.
-- Skrip ini menambahkan profil, role, ownership course, RLS, dan token FCM.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  name text not null default '',
  role text not null default 'seeker'
    check (role in ('seeker', 'owner', 'admin'))
);

alter table public.profiles enable row level security;

drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own
  on public.profiles for select to authenticated
  using (auth.uid() = id);

create or replace function public.user_has_role(_role text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid() and role = _role
  );
$$;

revoke all on function public.user_has_role(text) from public;
grant execute on function public.user_has_role(text) to authenticated;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, email, name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'name', ''),
    case
      when new.raw_user_meta_data->>'role' in ('seeker', 'owner')
        then new.raw_user_meta_data->>'role'
      else 'seeker'
    end
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Buat profil untuk akun yang sudah ada sebelum trigger dibuat.
insert into public.profiles (id, email, name, role)
select id, email, '', 'seeker'
from auth.users
on conflict (id) do nothing;

-- Kolom owner_id yang kosong pada data lama tetap tidak dapat diedit owner.
-- Isi owner_id secara manual hanya jika pemilik data lama sudah diverifikasi.
alter table public.courses
  add column if not exists owner_id uuid
  references auth.users(id) on delete set null;

alter table public.courses enable row level security;

-- Policy PostgreSQL bersifat permissive (digabung dengan OR). Hapus policy
-- lama pada tabel ini agar tidak ada policy umum yang melewati aturan baru.
do $$
declare
  existing_policy record;
begin
  for existing_policy in
    select policyname
    from pg_policies
    where schemaname = 'public' and tablename = 'courses'
  loop
    execute format('drop policy %I on public.courses', existing_policy.policyname);
  end loop;
end;
$$;

drop policy if exists courses_select_authenticated on public.courses;
create policy courses_select_authenticated
  on public.courses for select to authenticated
  using (true);

drop policy if exists courses_insert_owner on public.courses;
create policy courses_insert_owner
  on public.courses for insert to authenticated
  with check (
    owner_id = auth.uid()
    and (public.user_has_role('owner') or public.user_has_role('admin'))
  );

drop policy if exists courses_update_owner on public.courses;
create policy courses_update_owner
  on public.courses for update to authenticated
  using (owner_id = auth.uid() and public.user_has_role('owner'))
  with check (owner_id = auth.uid() and public.user_has_role('owner'));

drop policy if exists courses_delete_owner on public.courses;
create policy courses_delete_owner
  on public.courses for delete to authenticated
  using (owner_id = auth.uid() and public.user_has_role('owner'));

drop policy if exists courses_admin_all on public.courses;
create policy courses_admin_all
  on public.courses for all to authenticated
  using (public.user_has_role('admin'))
  with check (public.user_has_role('admin'));

create table if not exists public.device_tokens (
  token text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  platform text,
  updated_at timestamptz not null default now()
);

alter table public.device_tokens enable row level security;

drop policy if exists device_tokens_select_own on public.device_tokens;
create policy device_tokens_select_own
  on public.device_tokens for select to authenticated
  using (auth.uid() = user_id);

drop policy if exists device_tokens_insert_own on public.device_tokens;
create policy device_tokens_insert_own
  on public.device_tokens for insert to authenticated
  with check (auth.uid() = user_id);

drop policy if exists device_tokens_update_own on public.device_tokens;
create policy device_tokens_update_own
  on public.device_tokens for update to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists device_tokens_delete_own on public.device_tokens;
create policy device_tokens_delete_own
  on public.device_tokens for delete to authenticated
  using (auth.uid() = user_id);
