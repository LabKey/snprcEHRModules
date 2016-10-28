/*
 * Copyright (c) 2015-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
b.Id,
b.date,
b.TestName,
group_concat(b.result) as results

FROM (

SELECT
  b.Id,
  b.date,
  b.testId.name AS TestName,
  coalesce(b.runId, b.objectid) as runId,
  b.resultoorindicator,
  CASE
  WHEN b.result IS NULL THEN  b.qualresult
    ELSE CAST(CAST(b.result AS float) AS VARCHAR)
  END as result
FROM study.labworkResults b
WHERE b.testId.includeInPanel = true and b.qcstate.publicdata = true and b.testid.type = 'Surveillance'

) b

GROUP BY b.runid,b.id, b.date, b.TestName

PIVOT results BY TestName IN
(select name from snprc_ehr.lab_tests t WHERE t.includeInPanel = true AND Type='Surveillance')

