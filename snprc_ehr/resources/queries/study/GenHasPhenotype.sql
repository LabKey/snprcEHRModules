-- ETL source
-- 09-16-19
select distinct p.subjectId as Id,
                TRUE  as HasPhenotypesdata,
                now() as date,
                NULL as objectId
from Project."Core Facilities/Genetics".assay.general.Phenotypes.data p