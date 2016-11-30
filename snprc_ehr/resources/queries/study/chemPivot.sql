/*
 * Copyright (c) 2013-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
b.Id,
b.date,
b.TestName,
MAX(b.result) as results

FROM chemPivotInner b

GROUP BY b.runid,b.id, b.date, b.TestName

PIVOT results BY TestName IN
(select name from snprc_ehr.lab_tests t WHERE t.includeInPanel = true AND Type='Biochemistry')

