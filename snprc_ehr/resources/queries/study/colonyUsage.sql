/*
 * Copyright (c) 2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT
	gen.investigator,
	gen.genprotocol AS protocol,
	gen."M::gentotal",
	gen."F::gentotal",
	gen."U::gentotal",
	gt.total,
	gen.species_code
FROM
	(SELECT
		protocol.inves AS investigator,
		group_concat(DISTINCT protocol, ',') AS genprotocol,
		Id.Demographics.gender AS gender,
		Id.Demographics.species.arc_species_code AS species_code,
		count(*) AS gentotal
	FROM assignment WHERE isActive = true AND Id.Demographics.gender IS NOT NULL
	GROUP BY protocol.inves, Id.Demographics.gender, Id.Demographics.species.arc_species_code
	PIVOT gentotal BY gender IN ('M', 'F', 'U')) gen
	FULL JOIN
	(SELECT
		protocol.inves AS investigator,
		count(*) AS total
	FROM assignment WHERE isActive = true
	GROUP BY protocol.inves) gt ON gen.investigator = gt.investigator