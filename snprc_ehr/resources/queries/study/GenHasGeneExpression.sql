/*
 * Copyright (c) 2019-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
select distinct g.subjectId as Id,
                TRUE  as HasGeneExpressionData,
                now() as date,
                NULL as objectId
from Project."Core Facilities/Genetics".assay.general."Gene Expression".data g