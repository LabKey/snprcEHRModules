/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/********************************************************
  Query will feed the export ETL back to CAMP.

02.22.21 srr
Has objectID

 ********************************************************/
SELECT pi.ProjectItemId,
       pi.ParentObjectId,
       pi.SuperPkgId,
       pi.Active,
       pi.Container,
       pi.CreatedBy,
       pi.Created,
       pi.ModifiedBy,
       pi.Modified,
       pi.Lsid,
       pi.Objectid

FROM snd.ProjectItems pi