-- ETL source
select distinct g.subjectId as Id,
                TRUE  as HasGeneExpressionData,
                now() as date,
                NULL as objectId
from Project."Core Facilities/Genetics".assay.general."Gene Expression".data g