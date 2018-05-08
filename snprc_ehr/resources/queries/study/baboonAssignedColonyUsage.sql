SELECT
  accountGroup,
  protocol,
  species_code,
  M,
  F,
  U,
  Infant,
  Juvenile,
  Adult,
  Senior,
  SPF,
  Conventional,
  total from study.baboonAssignedColonyUsageQuery

UNION

select
  'TOTALS',
  NULL,
  'PC',
  sum(M),
  sum(F),
  sum(U),
  sum(Infant),
  sum(Juvenile),
  sum(Adult),
  sum(Senior),
  sum(SPF),
  sum(conventional),
  sum(total)
from study.baboonAssignedColonyUsageQuery

