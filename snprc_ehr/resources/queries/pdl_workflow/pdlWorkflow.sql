/*
  Purpose: ETL from SPF assay tables to clinpathRuns
  Author: Charles Peterson, Texas Biomedical Research Institute, September 20, 2018
 */
  select distinct
    case when d.snprc_id is NULL then
      d.pdl_animal_id
    else d.snprc_id end as Id,
    d.sample_date as date,
    d.report_date as datefinalized,
    d.procedure_id as serviceId,
    d.report_date as verifiedDate,
    d.procedure_id as servicerequested,
    'Surveillance' as type,
    d.file_name as remark,
    d.sample as sampleId

  from pdl_workflow.data as d
