/* Purpose: Query to create view combining SPF labworkResults assay and labworkResults table,
            superceding original labworkResults table in all uses.

   Author:  Charles Peterson, 10/29/2018

 */


select
  Id,
  date,
  project,
  serviceId,
  serviceTestId,
  testid,
  resultOORIndicator,
  value_type,
  result,
  units,
  qualresult,
  refRange,
  abnormal_flags,
  runid,
  enddate,
  method,
  remark,
  history
from study.labworkResults

union all

select
  Id,
  date,
  project,
  serviceId,
  serviceTestId,
  testid,
  resultOORIndicator,
  value_type,
  result,
  units,
  qualresult,
  refRange,
  abnormal_flags,
  runid,
  enddate,
  method,
  remark,
  history
from study.assay_labworkResults
