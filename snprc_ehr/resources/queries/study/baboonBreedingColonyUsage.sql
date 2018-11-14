/*
 * Copyright (c) 2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

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
  total from study.baboonBreedingColonyUsageQuery

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
from study.baboonBreedingColonyUsageQuery

