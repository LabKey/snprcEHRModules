/*
 * Copyright (c) 2015-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  b.id,
  b.date,
  b.testId,
  lt.testName,

  b.resultOORIndicator,
  b.result,
  b.units,
  b.qualresult,
  b.qcstate,
  b.taskid,
  b.runId
FROM study.labworkResults b
INNER JOIN snprc_ehr.labwork_panels AS lt
    ON b.serviceTestid = lt.rowId
           AND lt.ServiceId.Dataset='Biochemistry'
           AND (b.serviceTestid.includeInPanel = false OR b.serviceTestid.includeInPanel IS NULL)
           AND b.qcstate.publicdata = true

