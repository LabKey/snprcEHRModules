/*
 * Copyright (c) 2013-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
x.*,
y.servicerequested
FROM (
SELECT
  b.id,
  b.date,
  b.runId,
  b.TestName,
  MAX(b.result) as results

  FROM hematologyPivotInner b

  GROUP BY b.id, b.date, b.runId, b.TestName
  PIVOT results BY TestName IN
  (select name from snprc_ehr.lab_tests t WHERE t.includeInPanel = true AND Type='Hematology')
) X
INNER JOIN (
SELECT
  b.id,
  b.date,
  group_concat(distinct servicerequested, chr(10)) as servicerequested,
  b.runId
  FROM (

  SELECT
    b.id,
    b.date,
    b.testId.name AS TestName,
    b.runid.servicerequested AS servicerequested,
    coalesce(b.runId, b.objectid) as runId
  FROM study.labworkResults b
  WHERE b.testId.includeInPanel = true AND b.qcstate.publicdata = true and b.testid.type = 'Hematology'
  ) b

  GROUP BY b.id, b.date, b.runId
) Y
ON X.id = Y.id AND X.date = Y.date AND X.runId = Y.runId

