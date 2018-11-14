/*
 * Copyright (c) 2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT
  gen.accountGroup,
  pro.protocol AS protocol,
  gen.species_code as species_code,
  gen."M::gentotal" as M,
  gen."F::gentotal" as F,
  gen."U::gentotal" as U,
  age."Infant::ageTotal" as Infant,
  age."Juvenile::ageTotal" as Juvenile,
  age."Adult::ageTotal" as Adult,
  age."Senior::ageTotal" as Senior,
  col."pc_SPF::colonytotal" as SPF,
  col."pc_Conv::colonytotal" as Conventional,
  gt.total

FROM
  -- Gender --
  (SELECT
     aag.accountGroup AS accountGroup,
     aag.Id.Demographics.gender AS gender,
     aag.Id.Demographics.species.arc_species_code AS species_code,
     count(*) AS gentotal

   FROM study.ActiveAccountsWithGroup as aag
   WHERE aag.Id.Demographics.gender IS NOT NULL AND aag.Id.AgeClass.label IS NOT NULL AND aag.Id.Demographics.calculated_status = 'Alive'
         AND aag.Id.Demographics.species.arc_species_code = 'PC' AND aag.accountGroup in ('Holding', 'Naive', 'Non-naive')

   GROUP BY aag.accountGroup, aag.Id.Demographics.gender, aag.Id.Demographics.species.arc_species_code
   PIVOT gentotal BY gender IN ('M', 'F', 'U') ) gen

  INNER JOIN
  -- Age Class --
  (SELECT
     aag.accountGroup AS accountGroup,
     aag.Id.AgeClass.label AS ageClass,
     aag.Id.Demographics.species.arc_species_code AS species_code,
     count(*) AS agetotal

   FROM study.ActiveAccountsWithGroup as aag
   WHERE aag.Id.Demographics.gender IS NOT NULL AND aag.Id.AgeClass.label IS NOT NULL AND aag.Id.Demographics.calculated_status = 'Alive'
         AND aag.Id.Demographics.species.arc_species_code = 'PC' AND aag.accountGroup in ('Holding', 'Naive', 'Non-naive')

   GROUP BY  aag.accountGroup, aag.Id.AgeClass.label, aag.Id.Demographics.species.arc_species_code
   PIVOT agetotal BY ageClass IN ('Infant', 'Juvenile', 'Adult', 'Senior')) age
    ON gen.accountGroup = age.accountGroup AND gen.species_code = age.species_code

  INNER JOIN
  -- Colonies (pc_SPF, pc_Conv)
  (SELECT
     aag.accountGroup AS accountGroup,
     dcc.colony AS colony,
     aag.Id.Demographics.species.arc_species_code AS species_code,
     count(*) AS colonytotal

   FROM study.ActiveAccountsWithGroup as aag
     INNER JOIN study.demographicsCurrentColony as dcc on aag.id = dcc.id
   WHERE aag.Id.Demographics.gender IS NOT NULL AND aag.Id.Demographics.calculated_status = 'Alive'
   GROUP BY aag.accountGroup, dcc.colony, aag.Id.Demographics.species.arc_species_code

   PIVOT colonytotal BY colony IN (SELECT name FROM snprc_ehr.BaboonColonyGroups))  col -- ('pc_SPF', 'pc_Conv')) col
    ON gen.accountGroup = col.accountGroup AND gen.species_code = col.species_code

  INNER JOIN
  -- Total --
  (SELECT
     aag.accountGroup AS accountGroup,
     aag.Id.Demographics.species.arc_species_code AS species_code,
     count(*) AS total

   FROM study.ActiveAccountsWithGroup as aag
   WHERE aag.Id.Demographics.gender IS NOT NULL AND aag.Id.AgeClass.label IS NOT NULL AND aag.Id.Demographics.calculated_status = 'Alive'
         AND aag.Id.Demographics.species.arc_species_code = 'PC' AND aag.accountGroup in ('Holding', 'Naive', 'Non-naive')

   GROUP BY aag.accountGroup, aag.Id.Demographics.species.arc_species_code) gt
    ON gen.accountGroup = gt.accountGroup AND gen.species_code = gt.species_code

  LEFT OUTER JOIN

  -- protocol --
  (SELECT
     aag.accountGroup as accountGroup,
     aag.Id.Demographics.species.arc_species_code as species_code,
     protocol AS protocol
   FROM study.ActiveAccountsWithGroup as aag
     INNER JOIN study.assignment as a on aag.id = a.id
   WHERE a.isActive = true and a.assignmentStatus = 'A' AND aag.Id.Demographics.species.arc_species_code = 'PC'
         AND aag.Id.Demographics.species.arc_species_code = 'PC' and a.protocol = '278PC' AND aag.accountGroup in ('Holding', 'Naive', 'Non-naive')

   GROUP BY aag.accountGroup, protocol, aag.Id.Demographics.species.arc_species_code) pro
    ON gen.accountGroup = pro.accountGroup AND gen.species_code = pro.species_code


