PARAMETERS (
   	ANIMAL_ID VARCHAR,
    EVENT_DATE TIMESTAMP
)

-- Research Charge IDs
SELECT
    CAST(p.project AS VARCHAR(40)) AS admitProjectId,
    p.project AS projectId,
    sp.projectType AS projectType,
    0 AS admitId,
    sp.description AS projectText,
    GREATEST (p.startDate, aaa.date, sp.startDate) AS startDate,
    LEAST (p.endDate, TIMESTAMPADD('SQL_TSI_DAY', 1, aaa.endDate), TIMESTAMPADD('SQL_TSI_DAY', 1, sp.endDate), NOW()) AS endDate,
    sp.projectId AS projectId,
    sp.revisionNum AS revisionNum
FROM ehr.project AS p
         INNER JOIN snd.projects AS sp ON p.project = sp.referenceId
         INNER JOIN study.assignment aaa ON p.protocol = aaa.protocol AND aaa.assignmentStatus IN ( 'A', 'S')
WHERE aaa.id = ANIMAL_ID
  AND GREATEST (p.startDate, aaa.date, sp.startDate) <= EVENT_DATE
  AND LEAST (p.endDate, TIMESTAMPADD('SQL_TSI_DAY', 1, aaa.endDate), TIMESTAMPADD('SQL_TSI_DAY', 1, sp.endDate), NOW()) >= EVENT_DATE
-- Maintenance/Behavior Charge IDs
UNION
SELECT DISTINCT
    CAST(p.project AS varchar(40)) AS admitProjectId,
    p.project AS projectId,
    sp.projectType AS projectType,
    0 AS admitId,
    sp.description AS projectText,
    GREATEST (p.startDate, sp.startDate) AS startDate,
    LEAST (p.endDate, TIMESTAMPADD('SQL_TSI_DAY', 1, sp.endDate), NOW()) AS endDate,
    sp.projectId AS projectId,
    sp.revisionNum AS revisionNum
FROM snprc_ehr.validChargeBySpecies AS vcbs
         INNER JOIN ehr.project AS p ON p.project = vcbs.project
         INNER JOIN study.demographics AS d ON d.id = ANIMAL_ID
         INNER JOIN snd.projects AS sp ON vcbs.project = sp.referenceId AND sp.projectType in ('M', 'B') AND CAST(EVENT_DATE AS DATE) BETWEEN sp.startDate AND COALESCE(sp.endDate, NOW())
WHERE d.id = ANIMAL_ID AND vcbs.species = d.species.arc_species_code
  AND GREATEST (p.startDate, sp.startDate) <= EVENT_DATE
  AND LEAST (p.endDate, TIMESTAMPADD('SQL_TSI_DAY', 1, sp.endDate), NOW()) >= EVENT_DATE
-- Clinical Charge IDs
UNION
SELECT DISTINCT
    CAST(c.caseid AS varchar(40)) AS admitProjectId,
    p.project AS projectId,
    sp.projectType AS projectType,
    c.caseid AS admitId,
    c.problem + '/' + c.admitcomplaint AS projectText,
    GREATEST (c.date, sp.startDate) AS startDate,
    LEAST (c.enddate, TIMESTAMPADD('SQL_TSI_DAY', 1, sp.endDate), NOW()) AS endDate,
    sp.projectId AS projectId,
    sp.revisionNum AS revisionNum
FROM study.cases AS c
         INNER JOIN study.demographics AS d ON c.id = ANIMAL_ID
         INNER JOIN snprc_ehr.validChargeBySpecies AS vcbs ON c.id = ANIMAL_ID AND vcbs.species = d.species.arc_species_code
         INNER JOIN snd.projects AS sp ON vcbs.project = sp.referenceId AND sp.projectType = 'C' AND EVENT_DATE BETWEEN sp.startDate AND COALESCE(sp.endDate, NOW())
         INNER JOIN ehr.project AS p ON p.project = vcbs.project AND EVENT_DATE BETWEEN p.startDate AND COALESCE(p.endDate, NOW())
WHERE d.id = ANIMAL_ID
  AND vcbs.species = d.species.arc_species_code
  AND GREATEST (c.date, sp.startDate) <= EVENT_DATE
  AND LEAST (c.endDate, TIMESTAMPADD('SQL_TSI_DAY', 1, sp.endDate), NOW()) >= EVENT_DATE