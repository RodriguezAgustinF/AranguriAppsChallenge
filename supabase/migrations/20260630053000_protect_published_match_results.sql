begin;

create function public.protect_published_match_result()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if old.result_published_at is not null then
    raise exception using
      errcode = '55000',
      message = 'a match with an official result is immutable';
  end if;

  return case when tg_op = 'DELETE' then old else new end;
end;
$$;

comment on function public.protect_published_match_result() is
  'Prevents every update or deletion of a match after its official result is published.';

revoke execute on function public.protect_published_match_result() from public, anon, authenticated;

create trigger protect_published_match_result
  before update or delete on public.matches
  for each row execute function public.protect_published_match_result();

commit;
