-- ETL source
select distinct m.subjectId as Id,
                TRUE  as HasMicroSatellitesData,
                now() as date,
                NULL as objectId
from Project."Core Facilities/Genetics".assay.general.Microsatellites.data m