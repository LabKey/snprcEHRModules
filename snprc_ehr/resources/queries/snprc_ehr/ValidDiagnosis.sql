/*
 * Copyright (c) 2019-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/***************************************

Diagnosis (PDX) list for mobile dev.
  Will be refactored with real data
  at a later date.

  srr 07.10.2019

***************************************/
select distinct problem
from study.cases
where date > '8/1/2018'