-- Applied atomically with staging after delivered client checks.
do $activate$
declare changed integer;
begin
  update public.cosmetics set active=true,availability_start=statement_timestamp()
  where slug in ('boston-terrier','hearth-cat') and category='familiar'
    and price=180 and not premium and required_archetype is null
    and edition_type='standard' and collection_key is null
    and not active and availability_start is null and availability_end is null;
  get diagnostics changed = row_count;
  if changed<>2 then raise exception 'Expected two staged household familiars'; end if;
end;
$activate$;
