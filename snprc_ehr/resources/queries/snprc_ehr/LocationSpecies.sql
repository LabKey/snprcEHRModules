/***************************************

sourced from snprc_ehr.ActiveLocations
 Added outer join to valid locations

Returns room and Species (char2) if occupied
  NULL species if valid location w/o animals

  srr 07.17.2019

***************************************/
SELECT distinct d.species.arc_species_code as species,d2.room

FROM study.housing d2
         inner join study.demographics d
                    on d2.id = d.id
WHERE d2.enddate IS NULL
  AND d2.qcstate.publicdata = true
ORDER by d2.room;