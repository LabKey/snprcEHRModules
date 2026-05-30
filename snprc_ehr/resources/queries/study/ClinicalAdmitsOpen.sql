/*
 * Copyright (c) 2019-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/********************************************************************
Current open clinic admits (CASES)
For SNPRC mobile app


srr 10.29.2019
srr 11.14.19 Added alias for species and added CaseId
********************************************************************/

SELECT c.Id, c.date AS AdmitDate, c.enddate AS ReleaseDate, c.caseid as CaseId,
       c.category, c.problem AS PDX, c.admitcomplaint, c.resolution, c.objectid, c.assignedvet, c.assignedvet.displayName as VetName,
       c.Id.Demographics.species.arc_species_code as Species
FROM study.cases c
WHERE c.enddate IS NULL
--limit 30