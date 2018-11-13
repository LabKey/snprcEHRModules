/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT
  gen.investigator,
  pro.protocol AS protocol,
  gen.species_code,
  gen."M::gentotal" as M,
  gen."F::gentotal" as F,
  gen."U::gentotal" as U,
  age."Infant::ageTotal" as Infant,
  age."Juvenile::ageTotal" as Juvenile,
  age."Adult::ageTotal" as Adult,
  age."Senior::ageTotal" as Senior,
  col."pc_SPF::grouptotal" as SPF,
  col."pc_Conv::grouptotal" as Conventional,
  gt.total

FROM
  -- Gender --
  (SELECT
     protocol.inves AS investigator,
     Id.Demographics.gender AS gender,
     Id.Demographics.species.arc_species_code AS species_code,
     count(*) AS gentotal

   FROM assignment
   WHERE isActive = true AND Id.Demographics.gender IS NOT NULL AND Id.AgeClass.label IS NOT NULL AND protocol.inves IS NOT NULL and assignment.assignmentStatus = 'A'
   GROUP BY protocol.inves, Id.Demographics.gender, Id.Demographics.species.arc_species_code
   PIVOT gentotal BY gender IN ('M', 'F', 'U')) gen

  INNER JOIN
  -- Age Class --
  (SELECT
     protocol.inves AS investigator,
     Id.AgeClass.label AS ageClass,
     Id.Demographics.species.arc_species_code AS species_code,
     count(*) AS agetotal

   FROM assignment
   WHERE isActive = true AND Id.Demographics.gender IS NOT NULL AND Id.AgeClass.label IS NOT NULL AND protocol.inves IS NOT NULL and assignment.assignmentStatus = 'A'
   GROUP BY protocol.inves, Id.AgeClass.label, Id.Demographics.species.arc_species_code
   PIVOT agetotal BY ageClass IN ('Infant', 'Juvenile', 'Adult', 'Senior')) age
    ON gen.investigator = age.investigator AND gen.species_code = age.species_code

  INNER JOIN
  -- Colonies (pc_SPF, pc_Conv)
  (SELECT
     protocol.inves AS investigator,
     demographicsCurrentColony.colony AS colony,
     a.Id.Demographics.species.arc_species_code AS species_code,
     count(*) AS grouptotal

   FROM study.assignment as a
     inner join study.demographicsCurrentColony on a.id = demographicsCurrentColony.id
   WHERE isActive = true AND a.Id.Demographics.gender IS NOT NULL AND a.Id.AgeClass.label IS NOT NULL AND protocol.inves IS NOT NULL and a.assignmentStatus = 'A'
   GROUP BY protocol.inves, demographicsCurrentColony.colony, a.Id.Demographics.species.arc_species_code

   PIVOT grouptotal BY colony IN (SELECT name FROM snprc_ehr.BaboonColonyGroups))  col
    ON gen.investigator = col.investigator AND gen.species_code = col.species_code


  INNER JOIN
  -- Total --
  (SELECT
     protocol.inves AS investigator,
     Id.Demographics.species.arc_species_code AS species_code,
     group_concat(DISTINCT protocol, ',') AS gtprotocol,
     count(*) AS total

   FROM assignment
   WHERE isActive = true AND Id.Demographics.gender IS NOT NULL AND Id.AgeClass.label IS NOT NULL AND protocol.inves IS NOT NULL and assignment.assignmentStatus = 'A'
   GROUP BY protocol.inves, Id.Demographics.species.arc_species_code) gt
    ON gen.investigator = gt.investigator AND gen.species_code = gt.species_code

  LEFT OUTER JOIN

  -- protocol --
  (SELECT
     protocol.inves as investigator,
     Id.Demographics.species.arc_species_code as species_code,
     group_concat(DISTINCT protocol, ',') AS protocol
   FROM assignment
   WHERE isActive = true and assignment.assignmentStatus = 'A'
   GROUP BY protocol.inves, Id.Demographics.species.arc_species_code) pro
    ON gen.investigator = pro.investigator AND gen.species_code = pro.species_code
