/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT a.value as AcqCode,
       a.category as Category,
       rtrim(a.value) + ' - ' + a.description as DisplayValue,
       a.sort_order as SortOrder
from ehr_lookups.AcquisitionType as a
where a.date_disabled is null
