select
    substring(qae.oldrecordmap, locate('objectid=', qae.oldrecordmap) + length('objectid='), 36) as objectid,
    qae.date as modified

from auditLog.QueryUpdateAuditEvent as qae

WHERE qae.comment = 'A row was deleted.'
  and qae.QueryName = 'LookupSets'
  and qae.SchemaName = 'snd'