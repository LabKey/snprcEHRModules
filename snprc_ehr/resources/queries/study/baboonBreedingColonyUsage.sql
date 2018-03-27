/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT * from study.baboonBreedingColonyUsageQuery

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
  sum(total)
from study.baboonBreedingColonyUsageQuery

