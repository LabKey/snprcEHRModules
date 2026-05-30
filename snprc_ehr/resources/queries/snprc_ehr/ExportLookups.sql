/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT l.LookupSetId,
       l.Value,
       l.Displayable,
       l.SortOrder,
       l.Container,
       l.CreatedBy,
       l.Created,
       l.ModifiedBy,
       l.Modified,
       l.Lsid,
       l.LookupId,
       l.ObjectId
FROM snd.Lookups l