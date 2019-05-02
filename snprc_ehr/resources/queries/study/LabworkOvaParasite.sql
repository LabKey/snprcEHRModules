SELECT ServiceId.Dataset,  ServiceId.ServiceName, *
FROM snprc_ehr.labwork_panels
WHERE ServiceId.Dataset='Parasitology' and ServiceId.ServiceName in ('OVA & PARASITES' , 'OVA & PARASITES, URINE' )
SELECT
  l.id,
  l.date,
  l.project,
  l.testid,
  l.resultOORIndicator,
  l.value_type,
  lt.testName,
  l.result,
  l.qualresult,
  l.units,
  l.refRange,
  l.abnormal_flags,
  l.remark,
  l.description,
  l.runid,
  l.taskid,
  l.method,
  l.objectid,
  l.modified,
  l.modifiedby,
  l.created,
  l.createdby
FROM labworkResults as l
       inner join snprc_ehr.labwork_panels as lt
         on l.serviceTestid = lt.rowId and lt.TestId in (77, 201, 727)