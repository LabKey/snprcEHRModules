/*
  Purpose: ETL from SPF assay tables to assay_labworkResults and ultimately SurveillancePivot
  Author: Charles Peterson, Texas Biomedical Research Institute, October 17, 2018
 */
-- noinspection SqlNoDataSourceInspection
select distinct
  case when d.snprc_id is NULL then
    d.pdl_animal_id
    else d.snprc_id end as Id,
  d.sample_date as date,
  d.procedure_name as panelName,
  NULL as serviceTestId,
  d.procedure_id as serviceId,
  d.test_id as testid,
  d.test_name as test_name,
/*  d.Run as runId, */
  NULL as runId,
  NULL as result,
  'ST' as value_type,
  d.results as qualresult,
  d.file_name as remark,
  d.sample as sampleId

/*  ServiceName debugging hack
  ,d.test_id as refRange,
  d.procedure_id as abnormal_flags,
  d.test_name as resultOORIndicator */

from pdl_workflow.data as d
