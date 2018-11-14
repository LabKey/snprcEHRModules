/*
 * Copyright (c) 2015-2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  b.id,
  b.date,
  b.testId,
  b.testId.Name,

  b.resultOORIndicator,
  b.result,
  b.units,
  b.qualresult,
  b.qcstate,
  b.taskid,
  b.runId
FROM study.labworkResults b

WHERE b.testId.Type = 'Biochemistry' AND (b.testId.includeInPanel = false OR b.testId.includeInPanel IS NULL) AND b.qcstate.publicdata = true

