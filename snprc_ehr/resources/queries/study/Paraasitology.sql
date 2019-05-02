-- NON O&P
SELECT
  l.id,
  l.runid,
  l.runId.serviceRequested as PanelName,
  l.serviceTestId.testName as TestName,
  l.date,
  l.qualresult,

  lt.ServiceId.ServiceName,
  l.remark,
  l.description,

  l.taskid,
  l.method,
  l.objectid,
  l.modified,
  l.modifiedby,
  l.created,
  l.createdby
FROM labworkResults as l
       inner join snprc_ehr.labwork_panels as lt
                  on l.serviceTestid = lt.rowId
                    and lt.ServiceId.Dataset='Parasitology'
                    and lt.ServiceId.ServiceName NOT IN ('OVA & PARASITES' , 'OVA & PARASITES, URINE' )
