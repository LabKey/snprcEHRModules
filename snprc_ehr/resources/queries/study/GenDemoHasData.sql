Select d.Id,
       d.birth,
       d.death,
       d.calculated_status,
       d.dam,
       d.sire,
       d.gender,
       d.species,
       d.species.arc_species_code as ARC_species,
       IFNULL(CAST(g.HasGeneExpressionData AS INTEGER), 0) as HasGeneExpressionData,
       IFNULL(CAST(s.HasSNPData AS INTEGER), 0) as HasSNPData,
       IFNULL(CAST(m.HasMicrosatellitesData AS INTEGER), 0) as HasMicrosatellitesData,
       IFNULL(CAST(p.HasphenotypesData AS INTEGER), 0) as HasPhenotypeData
       
From study.demographics d
         LEFT OUTER JOIN study.GenFlagSNP s
                         ON 	s.id = d.id
         LEFT OUTER JOIN study.GenFlagGeneExpression g
                         ON 	g.id = d.id
         LEFT OUTER JOIN study.GenFlagMicrosatellites m
                         ON 	m.id = d.id
         LEFT OUTER JOIN study.GenFlagPhenotype p
                         ON 	p.id = d.id