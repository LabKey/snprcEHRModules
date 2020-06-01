-- Behavior Summary Reports
SELECT year(b.ReportDate)                         AS ReportYear,
       b.id                                         AS Id,
       --b.NotificationNumber,
       b.ReportDate,
       --b.CloseDateTm,
       b.Room                                       AS BehaviorLocation,
       b.Behavior,
       b.id.demographics.Gender                     AS Sex,
       b.id.demographics.Species.Arc_species_code   As SpeciesCode,
       b.id.demographics.Dam                        AS Dam,
       b.id.demographics.rearing_type               AS RearingType, -- int
       --b.id.demographics.rearing_type.description AS RearingDescription,
       b.id.demographics.species.arc_species_code.common_name AS Species,
       b.id.curLocation.room                      AS CurrentRoom
FROM study.study.BehaviorAbnormalAll b
-- restrict for testing
WHERE b.ReportDate > '1/1/2015'
--  AND b.id = '4X0039'
ORDER BY b.ReportDate desc