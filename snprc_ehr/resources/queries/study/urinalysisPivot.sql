SELECT
  b.Id,
  b.date,
  b.runId,
  b.panelName,
  b.TestName,
  MAX(b.result) as results

FROM urinalysisPivotInner b

GROUP BY b.runid,b.id, b.date, b.TestName, b.panelName

PIVOT results BY TestName IN
(select TestName from snprc_ehr.labwork_panels t
where t.includeInPanel = true AND t.ServiceId.Dataset='Urinalysis'
)