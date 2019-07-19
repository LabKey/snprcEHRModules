/***************************************

sourced from snprc_ehr.ActiveLocations
 Added outer join to valid locations

Returns room and Species (char2) if occupied
  NULL species if valid location w/o animals
  srr 07.17.2019

  Changed to an outer join.
    srr 04.19.2019
***************************************/
SELECT DISTINCT r.room AS room, d.id.Demographics.species.arc_species_code as species

FROM ehr_lookups.rooms r
         LEFT OUTER JOIN study.demographicsCurLocation d
                         on r.room = d.room

WHERE r.dateDisabled IS NULL
  AND CAST(r.room as DECIMAL) < 800.0;