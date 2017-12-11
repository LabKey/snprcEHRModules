select
  substring(dae.oldrecordmap, charindex('objectid=',dae.oldrecordmap, 0) + len('objectid='), 36) as objectid,
  dae.date as modified

from auditLog.DatasetAuditEvent as dae

WHERE dae.comment = 'A dataset record was deleted'
      and datasetid.name = 'Weight'