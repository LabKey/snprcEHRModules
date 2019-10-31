/********************************************************************
Current open clinic admits (CASES)
For SNPRC mobile app


srr 10.29.2019
********************************************************************/

SELECT c.Id, c.date AS AdmitDate, c.enddate AS ReleaseDate,
       c.category, c.problem AS PDX, c.admitcomplaint, c.resolution, c.objectid, c.assignedvet, c.assignedvet.displayName as VetName,
       c.Id.Demographics.species.arc_species_code
FROM study.cases c
WHERE c.enddate IS NULL
--limit 30