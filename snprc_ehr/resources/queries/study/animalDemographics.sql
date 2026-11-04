PARAMETERS
(
    dateParm TIMESTAMP DEFAULT null
)
SELECT
    d.id as id,
    d.gender as gender,
    d.id.MostRecentWeight.MostRecentWeight as weight,
    d.species.arc_species_code as species,
    CASE
        WHEN h.cage is null THEN h.room
        WHEN isnumeric(h.cage) = 1 THEN (h.room || '-' || cast(cast(h.cage as DECIMAL) as varchar) )
        ELSE (h.room || '-' || h.cage)
        END AS Location,
    h.room as room,
    h.cage as cage,
    d.id.age.ageInYears as age,
    d.calculated_status as status
FROM study.demographics d
INNER JOIN study.acq_disp as a on a.id = d.id
INNER JOIN study.housing as h on h.id = d.id
WHERE coalesce(dateParm, now()) between a.acq_date and coalesce(a.disp_date, now())
      and coalesce(dateParm, now()) between h.date and coalesce(h.enddate, now())
      and coalesce(d.id.demographics.lastDayAtCenter, now()) >= coalesce(dateParm, now())
