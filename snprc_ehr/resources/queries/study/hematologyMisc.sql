/*
 * Copyright (c) 2015-2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  b.id,
  b.date,
  b.testId,
  b.resultOORIndicator,
  b.result,
  b.units,
  b.qualresult,
  b.qcstate,
  b.taskid,
  b.runId
FROM study.labworkResults b

WHERE (testId.includeInPanel = FALSE OR b.testid.includeInPanel IS NULL) and b.qcstate.publicdata = true
