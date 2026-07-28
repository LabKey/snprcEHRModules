/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT DISTINCT s.species_code     as SpeciesCode,
                rtrim(sc.common_name)   as CommonName,
                s.species_code || ' (' || rtrim(s.arc_species_code) || ') - ' || rtrim(s.scientific_name)  || '/' || rtrim(sc.common_name) as DisplayColumn,
                s.scientific_name  as ScientificName,
                s.arc_species_code as arcSpeciesCode
FROM snprc_ehr.species AS s
INNER JOIN ehr_lookups.species_codes as sc on s.arc_species_code = sc.code
LEFT OUTER JOIN
     (
         SELECT d.species, d.birth
         FROM study.demographics AS d
     ) as x ON x.species = s.species_code
WHERE s.dateDisabled is null
  AND (
        age_in_years(x.birth, curdate()) <= 10 OR age_in_months(s.created, curdate()) <= 3
    )
