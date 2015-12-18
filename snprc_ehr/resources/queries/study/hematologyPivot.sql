/*
 * Copyright (c) 2013-2015 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
b.id,
b.date,
group_concat(distinct servicerequested, chr(10)) as servicerequested,
b.TestName,
group_concat(b.result) as results

FROM (

SELECT
  b.id,
  b.date,
  b.testId.name AS TestName,
  b.runid.servicerequested as servicerequested,
  coalesce(b.runId, b.objectid) as runId,
  b.resultoorindicator,
  CASE
  WHEN b.result IS NULL THEN  b.qualresult
    ELSE CAST(CAST(b.result AS float) AS VARCHAR)
  END as result
FROM study.labworkResults b
WHERE b.testId.includeInPanel = true AND b.qcstate.publicdata = true and b.testid.type = 'Hematology'
) b

GROUP BY b.id, b.date, b.runId, b.TestName
PIVOT results BY TestName IN
(select name from ehr_lookups.lab_tests t WHERE t.includeInPanel = true AND Type='Hematology')

