/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT pcj.PkgId,
       pcj.CategoryId,
       pcj.Container,
       pcj.CreatedBy,
       pcj.Created,
       pcj.ModifiedBy,
       pcj.Modified,
       pcj.Lsid,
       pcj.Objectid
FROM snd.PkgCategoryJunction pcj