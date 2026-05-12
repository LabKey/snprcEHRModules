select
    substring(dae.oldrecordmap, LOCATE('objectid=', dae.oldrecordmap) + LENGTH('objectid='), 36) as objectid,
    dae.date as modified

from auditLog.DatasetAuditEvent as dae

WHERE dae.comment = 'A dataset record was deleted'
  and datasetid.name = 'Demographics'