select
    -- locate() is case-sensitive on Postgres and the audit record map's key casing is not guaranteed,
    -- so search a lower-cased copy. lower() preserves length, so the offset stays valid for
    -- substring() on the original.
    substring(qae.oldrecordmap, locate('objectid=', lower(qae.oldrecordmap)) + length('objectid='), 36) as objectid,
    qae.date as modified

from auditLog.QueryUpdateAuditEvent as qae

WHERE qae.comment = 'A row was deleted.'
  and qae.QueryName = 'Lookups'
  and qae.SchemaName = 'snd'