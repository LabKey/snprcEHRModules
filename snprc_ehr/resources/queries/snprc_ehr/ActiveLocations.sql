/***************************************

Active location list for mobile dev.
Returns Species (char2) and room
for all locations that currently hold animals
  srr 07.10.2019

  This could be refactored out by restricting
    ActiveLocationsAll.sql to where species is NOT NULL
  srr 12.10.2019
***************************************/
SELECT distinct d.species.arc_species_code as species,d2.room, 	cast(d2.room_sortValue as double) as room_sortValue

FROM study.housing d2
         inner join study.demographics d
                    on d2.id = d.id
WHERE d2.enddate IS NULL
  AND d2.qcstate.publicdata = true
ORDER by cast(d2.room_sortValue as double);