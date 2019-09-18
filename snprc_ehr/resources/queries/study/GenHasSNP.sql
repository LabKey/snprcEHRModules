-- ETL source
-- 09-16-19
select distinct s.subjectId as Id,
                TRUE  as HasSNPData,
                now() as date,
                NULL as objectId
from Project."Core Facilities/Genetics".assay.general.SNPs.data s

