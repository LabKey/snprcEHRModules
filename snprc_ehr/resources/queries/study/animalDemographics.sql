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
        -- DECIMAL without explicit precision resolves to DECIMAL(18,0) on SQL Server (zero fractional digits)
        -- but to unspecified-scale NUMERIC on Postgres, which preserves any decimals from the source string.
        -- With h.cage stored as text like '7.00', that produced '7' on SS and '7.00' on PG. Pin the scale to 0
        -- explicitly so both databases strip the fractional part identically.
        WHEN isnumeric(h.cage) THEN (h.room || '-' || cast(cast(h.cage as DECIMAL(18, 0)) as varchar) )
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
