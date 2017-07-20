SELECT
b.Id,
b.date,
b.runid,
b.panelName,
b.TestName,
MAX(b.result) as results

FROM hematologyPivotInner b

GROUP BY b.runid, b.panelName, b.id, b.date, b.TestName

PIVOT results BY TestName IN
(select TestName from snprc_ehr.labwork_panels t
 where t.includeInPanel = true AND t.ServiceId.Dataset='Hematology'
)

