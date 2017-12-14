SELECT  aaa.id AS Id ,
        aaa.protocol AS Protocol ,
        p.name AS ProjectName ,
        p.project AS ChargeId ,
        NULL AS AdmitId ,
        'Research' AS ProjectType
FROM    study.assignment AS aaa
  INNER JOIN ehr.project p ON aaa.protocol = p.protocol
WHERE   aaa.date >= p.startdate
        AND COALESCE(aaa.enddate, curdate()) <= COALESCE(p.enddate, curdate())
        AND aaa.assignmentStatus IN ( 'A', 'S' ) -- assigned or screening
UNION
SELECT  c.id AS Id ,
        'n/a' AS Protocol ,
        p.name AS ProjectName ,
        p.project AS ChargeId ,
        c.caseid AS AdmitId ,
        'Clinical' AS ProjectType
FROM    study.cases AS c
  INNER JOIN study.demographics d ON c.id = d.id
  INNER JOIN snprc_ehr.species s ON d.species = s.species_code
  INNER JOIN snprc_ehr.ValidChargeBySpecies vcs ON s.arc_species_code = vcs.Species
                                                   AND vcs.Purpose = 'C'
                                                   AND vcs.Project >= 4000
  INNER JOIN ehr.project p ON vcs.Project = p.project
WHERE   c.date >= p.startdate
        AND COALESCE(c.enddate, curdate()) <= COALESCE(p.enddate, curdate())
UNION
SELECT  d.id AS Id ,
        'n/a' AS Protocol ,
        p.name AS ProjectName ,
        p.project AS ChargeId ,
        0 AS AdmitId ,
        'Maintenance' AS ProjectType
FROM    study.demographics AS d
  INNER JOIN snprc_ehr.species s ON d.species = s.species_code
  INNER JOIN snprc_ehr.ValidChargeBySpecies vcs ON s.arc_species_code = vcs.Species
                                                   AND vcs.Purpose = 'M'
                                                   AND vcs.Project >= 4000
  INNER JOIN ehr.project p ON vcs.Project = p.project
WHERE   d.birth >= p.startdate
        AND COALESCE(d.death, curdate()) <= COALESCE(p.enddate, curdate());

