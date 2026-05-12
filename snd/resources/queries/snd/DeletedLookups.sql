select
    substring(qae.oldrecordmap, LOCATE('objectid=', qae.oldrecordmap) + LENGTH('objectid='), 36) as objectid,
    qae.date as modified

from auditLog.QueryUpdateAuditEvent as qae

WHERE qae.comment = 'A row was deleted.'
  and qae.QueryName = 'Lookups'
  and qae.SchemaName = 'snd'