/*************************************************
GenDemoCustomizer.sql
  Demographics has gen data query for customizer
  Sourced from GenDemoHasData.sql
srr 10.14.19
*************************************************/

Select d.Id,
       /*
       d.birth,
       d.death,
       d.calculated_status,
       d.dam,
       d.sire,
       d.gender,
       d.species,
       d.species.arc_species_code as ARC_species,
       */
       IFNULL(g.HasGeneExpressionData,0) as HasGeneExpressionData,
       IFNULL(s.HasSNPData,0) as HasSNPData,
       IFNULL(m.HasMicrosatellitesData,0) as HasMicrosatellitesData,
       IFNULL(p.HasphenotypesData,0) as HasPhenotypeData

From study.demographics d
         LEFT OUTER JOIN study.GenFlagSNP s
                         ON 	s.id = d.id
         LEFT OUTER JOIN study.GenFlagGeneExpression g
                         ON 	g.id = d.id
         LEFT OUTER JOIN study.GenFlagMicrosatellites m
                         ON 	m.id = d.id
         LEFT OUTER JOIN study.GenFlagPhenotype p
                         ON 	p.id = d.id