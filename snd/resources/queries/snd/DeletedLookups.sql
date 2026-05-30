/*
 * Copyright (c) 2023-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
select
    substring(qae.oldrecordmap, locate('objectid=', qae.oldrecordmap) + length('objectid='), 36) as objectid,
    qae.date as modified

from auditLog.QueryUpdateAuditEvent as qae

WHERE qae.comment = 'A row was deleted.'
  and qae.QueryName = 'Lookups'
  and qae.SchemaName = 'snd'