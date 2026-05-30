/*
 * Copyright (c) 2019-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/********************************************************
Recent, active, admitting complaint  Query for  Grok.

Restricted to over 20 occurrences in the last two years.
Is free text.


srr 07.30.2019
********************************************************/

select AdmitComplaint
from study.cases c
where date > timestampadd('SQL_TSI_YEAR', -2,curdate())
group by admitcomplaint
having count(*) > 10