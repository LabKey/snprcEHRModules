/*
 * Copyright (c) 2019-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
-- ETL source
-- 09-16-19
select distinct p.subjectId as Id,
                TRUE  as HasPhenotypesdata,
                now() as date,
                NULL as objectId
from Project."Core Facilities/Genetics".assay.general.Phenotypes.data p