SELECT
  b.Id,
  b.date,
  b.runId.serviceRequested as panelName,
  b.serviceTestId.testName AS TestName,

  coalesce(b.runId, b.objectid) as runId,
  b.resultoorindicator,
  CASE
  WHEN b.result IS NULL THEN  b.qualresult
  ELSE CAST(CAST(b.result AS float) AS VARCHAR)
  END as result
FROM study.labworkResults b
WHERE b.serviceTestId.includeInPanel = true and b.qcstate.publicdata = true and b.serviceTestid.ServiceId.Dataset = 'Urinalysis'