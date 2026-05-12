Select d.Id,
       d.birth,
       d.death,
       d.calculated_status,
       d.dam,
       d.sire,
       d.gender,
       d.species,
       d.species.arc_species_code as ARC_species,
       IFNULL(g.HasGeneExpressionData, false) as HasGeneExpressionData,
       IFNULL(s.HasSNPData, false) as HasSNPData,
       IFNULL(m.HasMicrosatellitesData, false) as HasMicrosatellitesData,
       IFNULL(p.HasphenotypesData, false) as HasPhenotypeData
       
From study.demographics d
         LEFT OUTER JOIN study.GenFlagSNP s
                         ON 	s.id = d.id
         LEFT OUTER JOIN study.GenFlagGeneExpression g
                         ON 	g.id = d.id
         LEFT OUTER JOIN study.GenFlagMicrosatellites m
                         ON 	m.id = d.id
         LEFT OUTER JOIN study.GenFlagPhenotype p
                         ON 	p.id = d.id