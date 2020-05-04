
-- TODO: Do we want to limit selection to animals that were co-located with dam?
SELECT d.id as Sire,
       d.species as Species,
       d.species.arc_species_code as arc_species,
       d.gender,
       d.birth,
       x.minAdultAge adultAge,
       ROUND(CONVERT(age_in_months(d.birth, timestampadd('SQL_TSI_DAY', -y.gestation, curdate()) ), DOUBLE) / 12.0, 1)  as ageAtTime,
       y.species as g_species,
       timestampadd('SQL_TSI_DAY', -y.gestation, curdate()) as conceptionDate

FROM study.demographics AS d
         INNER JOIN (
    SELECT "min" AS minAdultAge, species, gender, label
    FROM ehr_lookups.ageclass AS ac1
) as x ON d.species.arc_species_code = x.species and x.label = 'Adult' AND (x.gender = 'M' OR x.gender is NULL)

-- hard code until the gestation data is available in LK - use 185 if we don't have a value
         INNER JOIN (
    SELECT 173 as gestation, 'PC' as species
    UNION ALL
    SELECT 143 as gestation, 'CJ' as species
    UNION ALL
    SELECT 160 as gestation, 'MM' as species
    UNION ALL
    SELECT 155 as gestation, 'MF' as species
    UNION ALL
    SELECT 223 as gestation, 'PT' as species
    UNION ALL
    SELECT 185 as gestation, 'O' as species
) AS y ON CASE WHEN d.species.arc_species_code IN ('PC', 'CJ', 'MM', 'MF', 'PT') then d.species.arc_species_code ELSE 'O' END = y.species

         INNER JOIN study.acq_disp as ad on d.id = ad.id

WHERE d.gender = 'M'
-- age at conception is greater or equal to minimum adult age
  AND x.minAdultAge <= ROUND(CONVERT(age_in_months(d.birth, timestampadd('SQL_TSI_DAY', -y.gestation, curdate())), DOUBLE) / 12.0, 1)
-- ensure animal was at txbiomed on date of conception
  AND timestampadd('SQL_TSI_DAY', -y.gestation, curdate()) BETWEEN ad.acq_date AND COALESCE(ad.disp_date, curdate())
-- make sure animal was alive (at center) on conception date
  AND COALESCE(d.lastDayAtCenter, curdate()) > timestampadd('SQL_TSI_DAY', -y.gestation, curdate())
