/*
 * Copyright (c) 2017-2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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

