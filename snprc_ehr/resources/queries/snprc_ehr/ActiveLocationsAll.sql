/***************************************

Valid location list for mobile dev.
Returns:
    Species (char2) for occupied rooms and NULL species empty rooms.
    room (as string) for valid locations


outer join to derived table (activelocations.sql)

Restricting this query to where species is NOT NULL will
  yield the same result set as ActiveLocations.sql
  srr 12.10.2019
***************************************/


SELECT  h.species AS species, r.room AS room--, cast(r.room as FLOAT) fRoom
FROM ehr_lookups.rooms r
         LEFT OUTER JOIN (
    -- derived table (ActiveLocation.SQL from July 2019)
    SELECT distinct d.species.arc_species_code as species,d2.room AS room
    FROM study.housing d2
             inner join study.demographics d
                        on d2.id = d.id
    WHERE d2.enddate IS NULL
      AND d2.qcstate.publicdata = true
) h
                         ON r.room = h.room
where r.dateDisabled is null
  and cast(r.room as FLOAT) < 800
order by cast(r.room as FLOAT)