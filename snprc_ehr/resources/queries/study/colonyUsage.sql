/*
 * Copyright (c) 2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT
	gen.investigator,
	gen.genprotocol AS protocol,
	gen.species_code,
	gen."M::gentotal",
	gen."F::gentotal",
	gen."U::gentotal",
	age."Infant::ageTotal",
	age."Juvenile::ageTotal",
	age."Adult::ageTotal",
	age."Senior::ageTotal",
	ped."baboon1::grouptotal",
	ped."baboon2::grouptotal",
	ped."baboon3::grouptotal",
	--ped.*,
	gt.total
FROM
	(SELECT
		protocol.inves AS investigator,
		group_concat(DISTINCT protocol, ',') AS genprotocol,
		Id.Demographics.gender AS gender,
		Id.Demographics.species.arc_species_code AS species_code,
		count(*) AS gentotal
	FROM assignment WHERE isActive = true AND Id.Demographics.gender IS NOT NULL AND Id.AgeClass.label IS NOT NULL AND protocol.inves IS NOT NULL
	GROUP BY protocol.inves, Id.Demographics.gender, Id.Demographics.species.arc_species_code
	PIVOT gentotal BY gender IN ('M', 'F', 'U')) gen
	INNER JOIN
	(SELECT
		protocol.inves AS investigator,
     	group_concat(DISTINCT protocol, ',') AS ageprotocol,
		Id.AgeClass.label AS ageClass,
		Id.Demographics.species.arc_species_code AS species_code,
     	count(*) AS agetotal
	FROM assignment WHERE isActive = true AND Id.Demographics.gender IS NOT NULL AND Id.AgeClass.label IS NOT NULL AND protocol.inves IS NOT NULL
	GROUP BY protocol.inves, Id.AgeClass.label, Id.Demographics.species.arc_species_code
	PIVOT agetotal BY ageClass IN ('Infant', 'Juvenile', 'Adult', 'Senior')) age
	ON gen.investigator = age.investigator AND gen.species_code = age.species_code AND gen.genprotocol = age.ageprotocol
	INNER JOIN
    (SELECT
		protocol.inves AS investigator,
     	group_concat(DISTINCT protocol, ',') AS grprotocol,
		Id.activeGroups.PedigreeGroup.name AS pedigree,
		Id.Demographics.species.arc_species_code AS species_code,
     	count(*) AS grouptotal
	FROM assignment WHERE isActive = true AND Id.Demographics.gender IS NOT NULL AND Id.AgeClass.label IS NOT NULL AND protocol.inves IS NOT NULL
	GROUP BY protocol.inves, Id.activeGroups.PedigreeGroup.name, Id.Demographics.species.arc_species_code
	PIVOT grouptotal BY pedigree IN (SELECT name FROM ehr.pedigreeGroups)) ped
	ON gen.investigator = ped.investigator AND gen.species_code = ped.species_code AND gen.genprotocol = ped.grprotocol
	INNER JOIN
	(SELECT
		protocol.inves AS investigator,
     	Id.Demographics.species.arc_species_code AS species_code,
     	group_concat(DISTINCT protocol, ',') AS gtprotocol,
		count(*) AS total
	FROM assignment WHERE isActive = true AND Id.Demographics.gender IS NOT NULL AND Id.AgeClass.label IS NOT NULL AND protocol.inves IS NOT NULL
	GROUP BY protocol.inves, Id.Demographics.species.arc_species_code) gt ON gen.investigator = gt.investigator AND gen.species_code = gt.species_code AND gen.genprotocol = gt.gtprotocol