/***************************************

Active location list for mobile dev.
Returns Species (char2) and room
for all locations that currently hold animals
  srr 07.10.2019

***************************************/
SELECT distinct d.species.arc_species_code as species,d2.room

FROM study.housing d2
         inner join study.demographics d
                    on d2.id = d.id
WHERE d2.enddate IS NULL
  AND d2.qcstate.publicdata = true
ORDER by d2.room;