-- Jalankan untuk memperbarui trigger jika worksheet9.sql sudah pernah diterapkan.
-- Pendaftar baru selalu mendapat role seeker; owner/admin diberikan oleh admin.
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
    'seeker'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;
