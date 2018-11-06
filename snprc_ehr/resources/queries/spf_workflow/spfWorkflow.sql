/*
  Purpose: ETL from SPF assay tables to clinpathRuns
  Author: Charles Peterson, Texas Biomedical Research Institute, September 20, 2018
 */
  select distinct
    d.snprc_id as Id,
    d.sample_date as date,
    d.report_date as datefinalized,
    d.procedure_id as serviceId,
    d.report_date as verifiedDate,
    d.procedure_id as servicerequested,
    'Surveillance' as type,
    d.file_name as remark,
    d.sample as sampleId

  from spf_workflow.data as d
