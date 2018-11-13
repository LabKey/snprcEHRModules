select
  Id,
  date,
  enddate,
  type,
  tissue,
  project,
  instructions,
  servicerequested,
  units,
  serviceId,
  collectedBy,
  sampleId,
  collectionMethod,
  method,
  sampleQuantity,
  quantityUnits,
  chargetype,
  verifiedDate,
  datefinalized,
  remark,
  history
from study.clinpathRuns

union all

select
  Id,
  date,
  enddate,
  type,
  tissue,
  project,
  instructions,
  servicerequested,
  units,
  serviceId,
  collectedBy,
  sampleId,
  collectionMethod,
  method,
  sampleQuantity,
  quantityUnits,
  chargetype,
  verifiedDate,
  datefinalized,
  remark,
  history
from study.assay_clinpathRuns