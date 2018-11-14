/*
 * Copyright (c) 2016-2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT
  investigator,
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
  total

from study.colonyUsageQuery

  UNION

select
'TOTALS',
  NULL,
  'pc',
  sum(M),
  sum(F),
  sum(U),
  sum(Infant),
  sum(Juvenile),
  sum(Adult),
  sum(Senior),
  sum(SPF),
  sum(Conventional),
  sum(total)
from study.colonyUsageQuery