/*
 * Copyright (c) 2019-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT p.ProjectId,
       p.RevisionNum,
       p.ReferenceId,
       p.StartDate,
       p.EndDate,
       p.Description,
       p.Active,
       vc.Species,
       vc.Purpose
FROM snd.Projects p
INNER JOIN snprc_ehr.ValidChargeBySpecies vc ON p.ReferenceId = vc.Project
WHERE p.EndDate > curdate() AND p.Active = true AND vc.Purpose IN ('C', 'M', 'B')