-- Same atomic transaction as staging; no artificial Halloween cutoff.
do $activate$
declare changed integer;
begin
  update public.cosmetics set active=true,availability_start=statement_timestamp()
  where collection_key='autumn-hearth' and slug in ('amberfall-window','maple-hearth-rug','mooncap-grove','harvest-lanterns','sages-rest')
    and not active and availability_start is null and availability_end is null;
  get diagnostics changed = row_count;
  if changed<>5 then raise exception 'Expected five staged Autumn Hearth entries'; end if;
end;
$activate$;
