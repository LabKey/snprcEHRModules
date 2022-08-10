/*
    Marmoset stats for transfer to Marmoset Coordinating Center (MMC)
 */
-- infant history queries
WITH cte0 AS
         ( -- default - everyone starts at 0
             SELECT d.id, 0 AS experience
             FROM study.demographics AS d
             WHERE d.calculated_status = 'Alive' AND d.species = 'CTJ'
         ),
     cte1 as
         ( -- sibling experience
             SELECT h.id AS id,
                    ac.label AS ageclass,
                    c.TargetDate,
                    h.room,
                    h.cage
             FROM study.housing AS h
                      INNER JOIN study.demographics AS d ON h.id = d.id  AND d.species = 'CTJ'
                      INNER JOIN ehr_lookups.calendar AS c ON c.TargetDate BETWEEN CAST(h.date AS DATE) AND CAST(COALESCE(h.enddate, NOW()) AS DATE)
                      INNER JOIN ehr_lookups.ageclass AS ac ON timestampdiff('SQL_TSI_DAY', d.birth, c.TargetDate) BETWEEN ac."min" * 365 AND COALESCE(ac."max", 99) * 365 AND ac.species = 'CJ'
             WHERE ac.label IN ('Infant') AND timestampdiff('SQL_TSI_DAY',d.birth, c.TargetDate) >= 14 AND h.cage IS NOT NULL
         ),

     cte2 AS
         ( -- rearings with offspring that survived 14 or less days
             SELECT b.dam, COUNT(*) AS num_offspring
             FROM study.demographics AS d
                      INNER JOIN study.birth AS b ON b.dam = d.id AND b.birth_code IN (1, 2, 3, 6) -- get offspring for dam
                      INNER JOIN study.demographics AS d2 ON b.id = d2.id -- offspring's demographics
                      --INNER JOIN study.animalaccounts AS aa ON b.dam = aa.id AND aa.enddate IS NULL -- dam's active account
                      --INNER JOIN snprc_ehr.validAccounts AS va ON va.account = aa.account AND va.accountGroup = 'Breeder'
             WHERE timestampdiff('SQL_TSI_DAY', b.date, COALESCE(d2.death, NOW()) ) <= 14 -- offspring that lived 14 days or less
               AND d.species = 'CTJ' AND d.calculated_status = 'Alive'
             GROUP BY b.dam
         ),

     cte3 AS
         ( -- only successful rearings
             SELECT b.dam, COUNT(*) AS num_offspring
             FROM study.demographics AS d
                      INNER JOIN study.birth AS b ON b.dam = d.participantid AND b.birth_code IN (1, 2) -- get offspring for dam
                      INNER JOIN study.demographics AS d2 ON b.id = d2.id -- offspring's demographics
                      --INNER JOIN study.animalaccounts AS aa ON b.dam = aa.id AND aa.enddate IS NULL -- dam's active account
                      --INNER JOIN snprc_ehr.validAccounts AS va ON va.account = aa.account AND va.accountGroup = 'Breeder'
             WHERE timestampdiff('SQL_TSI_DAY', b.date, COALESCE(d2.death, NOW()) ) > 14 -- offspring that lived more than 14 days
               AND d.species = 'CTJ' AND d.calculated_status = 'Alive'
             GROUP BY b.dam

         )

SELECT
    a.Id,
    e.ageClass,
    e.U24_Status,
    e.available_to_transfer,
    e.current_housing_status,
    GREATEST( a.experience, b.experience, c.experience, d.experience ) AS infant_history,
    NULL as fertility_status,
    NULL as medical_history,
    now() as run_date_tm
FROM

-- default - everyone starts at 0
(
    SELECT cte0.id, cte0.experience
    FROM cte0
) a

    LEFT OUTER JOIN
-- sibling experience
    (
        SELECT
            h.Id, 1 AS experience

        FROM study.housing AS h
                 INNER JOIN cte1 ON h.room = cte1.room AND h.cage = cte1.cage AND cte1.TargetDate BETWEEN h.date AND COALESCE(h.enddate, NOW())
                 INNER JOIN study.demographics AS d ON h.id = d.id AND d.calculated_status = 'Alive' AND d.species = 'CTJ'
                 INNER JOIN ehr_lookups.ageclass AS ac ON timestampdiff('SQL_TSI_DAY', d.birth, cte1.TargetDate) BETWEEN ac."min" * 365 AND COALESCE(ac."max", 99) * 365 AND ac.species = 'CJ'
        WHERE ac.label = 'Juvenile'
        GROUP BY h.id
    ) b ON b.Id = a.Id

    LEFT OUTER JOIN
-- unsuccessful rearing
    (
        SELECT cte2.dam AS Id, 2 AS experience
        FROM cte2
        WHERE NOT EXISTS (SELECT 1 as n FROM cte3 WHERE cte2.dam = cte3.dam)
        GROUP BY cte2.dam
    ) c ON c.id = a.id

    LEFT OUTER JOIN
-- successful rearing
    (
        SELECT cte3.dam AS Id, 3 AS experience
        FROM cte3
        GROUP BY cte3.dam
    ) d ON d.id = a.id

    INNER JOIN
-- U24 Status & Available to Transfer & current housing status
    (
        SELECT aa.id,
               d.species,
               ac.label AS ageClass,
               CASE WHEN aa.account IN('4876-001-00', '3508-402-12') THEN 1 ELSE 0 END AS U24_Status,
               CASE WHEN aa.account = '3508-402-12' AND ac.label = 'Adult' THEN 1 ELSE 0 END AS available_to_transfer,
               CASE WHEN do.HousingStatus.Description = 'Single' THEN 0 --single housed
                    WHEN do.HousingStatus.Description = 'Group' AND va.accountGroup <> 'Breeder' THEN 1 -- natal family unit
                    WHEN do.HousingStatus.Description IN ('Paired', 'Group') AND va.accountGroup = 'Breeder' THEN 2 -- active breeding
                    WHEN do.HousingStatus.Description = 'Paired' AND va.accountGroup <> 'Breeder' THEN 3 -- social non breeding
                    WHEN do.HousingStatus IS NULL and ac.label = 'Infant' THEN 1 -- *Asumption* we don't yet have observation data and animal is an infant - assume it is with its dam
                    ELSE NULL END AS current_housing_status
        FROM study.animalaccounts AS aa
                 INNER JOIN study.demographics AS d ON aa.id = d.id AND d.calculated_status = 'Alive' AND d.species = 'CTJ'
                 INNER JOIN ehr_lookups.ageclass AS ac ON timestampdiff('SQL_TSI_DAY',d.birth, NOW()) BETWEEN ac."min" * 365 AND COALESCE(ac."max", 99) * 365 AND ac.species = 'CJ'
                 LEFT JOIN study.dailyobservations AS do ON do.id = d.id AND CAST(do.date AS DATE) = timestampadd('SQL_TSI_DAY', -1, curdate())  --use previous days data to avoid data entry lag
                 INNER JOIN snprc_ehr.validAccounts AS va ON aa.account = va.account
        WHERE aa.enddate IS NULL

    ) e ON e.id = a.id