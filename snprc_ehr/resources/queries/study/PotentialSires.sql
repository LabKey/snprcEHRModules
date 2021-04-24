PARAMETERS
(
    birthdateParm TIMESTAMP DEFAULT '01/01/1900',
    selectedOptionParm VARCHAR DEFAULT 'Birth'  -- Birth or Acquisition
)
-- TODO: Do we want to limit selection to animals that were co-located with dam?
SELECT distinct d.id as Sire,
       d.species as Species,
       d.species.arc_species_code as ArcSpeciesCode,
       d.gender as Gender,
       d.birth as BirthDate,
       d.id.age.ageInYears as Age,
       ROUND(CAST(age_in_months(d.birth, y.minConceptionDate ) AS DOUBLE) / 12.0, 1) as AgeOnConceptionDate,
       x.minAdultAge as MinAdultAge

FROM study.demographics AS d
         INNER JOIN (
    SELECT "min" AS minAdultAge,
           coalesce("max", 10) AS maxAdultAge, -- some species may be missing maxAdultAge
           species,
           gender,
           label
    FROM ehr_lookups.ageclass AS ac
) as x ON d.species.arc_species_code = x.species and x.label = 'Adult' AND (x.gender = 'M' OR x.gender is NULL)

-- hard code until the gestation data is available in LK - use 185 if we don't have a value
         INNER JOIN (
    SELECT 173 as gestation, timestampadd('SQL_TSI_DAY', -173, birthdateParm ) as minConceptionDate, 'PC' as species
    UNION ALL
    SELECT 143 as gestation, timestampadd('SQL_TSI_DAY', -143, birthdateParm ) as minConceptionDate, 'CJ' as species
    UNION ALL
    SELECT 160 as gestation, timestampadd('SQL_TSI_DAY', -160, birthdateParm ) as minConceptionDate, 'MM' as species
    UNION ALL
    SELECT 155 as gestation, timestampadd('SQL_TSI_DAY', -155, birthdateParm ) as minConceptionDate, 'MF' as species
    UNION ALL
    SELECT 223 as gestation, timestampadd('SQL_TSI_DAY', -223, birthdateParm ) as minConceptionDate, 'PT' as species
    UNION ALL
    SELECT 22 as gestation, timestampadd('SQL_TSI_DAY', -22, birthdateParm ) as minConceptionDate, 'MA' as species
    UNION ALL
    SELECT 185 as gestation, timestampadd('SQL_TSI_DAY', -185, birthdateParm ) as minConceptionDate, 'O' as species
) AS y ON CASE WHEN d.species.arc_species_code IN ('PC', 'CJ', 'MM', 'MF', 'PT','MA') then d.species.arc_species_code ELSE 'O' END = y.species
INNER JOIN study.acq_disp as ad on d.id = ad.id
WHERE d.gender = 'M'
-- age at conception is greater or equal to minimum adult age
  -- LK has trouble matching parameters correctly using the code below, so minConceptionDate was added to the y result set
  --AND x.minAdultAge <= ROUND(CAST(age_in_months(d.birth, timestampadd('SQL_TSI_DAY', -y.gestation, coalesce(birthdateParm, curdate()) ) ) AS DOUBLE) / 12.0, 1)
  AND ROUND(CAST(age_in_months(d.birth, y.minConceptionDate ) AS DOUBLE) / 12.0, 1) between x.minAdultAge and x.maxAdultAge
-- ensure animal was at txbiomed on date of conception for birth type acquisitions
  AND (timestampadd('SQL_TSI_DAY', -y.gestation, birthdateParm) BETWEEN ad.acq_date AND COALESCE(ad.disp_date, birthdateParm) OR selectedOptionParm = 'Acquisition')
-- make sure animal was alive (at center) on conception date for birth type acquisitions
  AND (COALESCE(d.lastDayAtCenter, birthdateParm) >= timestampadd('SQL_TSI_DAY', -y.gestation, birthdateParm) OR selectedOptionParm = 'Acquisition')
-- drop off animals that were not alive on the conception date
  AND d.id.age.ageInYears >= ROUND(CAST(age_in_months(d.birth, y.minConceptionDate ) AS DOUBLE) / 12.0, 1)
