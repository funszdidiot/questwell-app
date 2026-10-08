-- Use only after the exact reviewed client assets are served.
-- Purchases close at the approved exclusive boundary; active remains true for owners.
do $activate$
declare changed integer;
begin
  if statement_timestamp()>='2026-11-09T06:00:00Z'::timestamptz then
    raise exception 'Halloween purchase window has already closed';
  end if;
  if (select count(*) from public.cosmetics where slug in
    ('hallowed-hearth','velvet-batwing-chair','moonbrew-side-table',
     'witchlight-bookcase','moonweb-rug','midnight-visitors-print')
    and not active and availability_start is null
    and availability_end='2026-11-09T06:00:00Z'::timestamptz)<>6 then
    raise exception 'Expected six staged Halloween entries';
  end if;
  update public.cosmetics set active=true,availability_start=statement_timestamp()
  where slug in ('hallowed-hearth','velvet-batwing-chair','moonbrew-side-table',
    'witchlight-bookcase','moonweb-rug','midnight-visitors-print');
  get diagnostics changed = row_count;
  if changed<>6 then raise exception 'Unexpected Halloween activation count'; end if;
end;
$activate$;
