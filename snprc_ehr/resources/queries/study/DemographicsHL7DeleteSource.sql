/*
 * Copyright (c) 2022-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
select
    substring(dae.oldrecordmap, charindex('objectid=',dae.oldrecordmap, 0) + len('objectid='), 36) as objectid,
    dae.date as modified

from auditLog.DatasetAuditEvent as dae

WHERE dae.comment = 'A dataset record was deleted'
  and datasetid.name = 'Demographics'