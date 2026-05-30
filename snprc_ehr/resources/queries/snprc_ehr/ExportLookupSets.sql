/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT ls.LookupSetId,
       ls.SetName,
       ls.Label,
       ls.Description,
       ls.Container,
       ls.CreatedBy,
       ls.Created,
       ls.ModifiedBy,
       ls.Modified,
       ls.Lsid,
       ls.ObjectId
FROM snd.LookupSets ls