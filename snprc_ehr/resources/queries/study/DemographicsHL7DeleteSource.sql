select
    -- LOCATE is case-sensitive on Postgres and the audit record map's key casing is not guaranteed,
    -- so search a lower-cased copy. lower() preserves length, so the offset stays valid for
    -- substring() on the original.
    substring(dae.oldrecordmap, LOCATE('objectid=', lower(dae.oldrecordmap)) + LENGTH('objectid='), 36) as objectid,
    dae.date as modified

from auditLog.DatasetAuditEvent as dae

WHERE dae.comment = 'A dataset record was deleted'
  -- The dataset is named 'demographics' in lower case. Postgres compares this exactly, so the previous
  -- 'Demographics' matched nothing and the query returned no rows; SQL Server matches either spelling.
  and datasetid.name = 'demographics'