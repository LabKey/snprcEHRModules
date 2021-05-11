
/**************************************************************
Sourced from ReportTcruziPositiveSummary
  Purpose is to report all summary data on T. cruzi tests.

  Changed to CASE to report single value for result (i.e. combining seroPos and Positive)
  Runs as expected in SQLdbx.
  srr 04.16.2021
    Added IND and INDETERMINATE
    to results CASE
  srr 04.20.21

  This report is for positive only, therefore restricting
  in each subquery and not the unioned result.  Did not remove
  negative or indeterminate from case, but will never be used.
  Hope is to one day drive all TC reports from same SQL.
  No longer reporting NumTests.  Purpose of this report is to
  only report first positive.
  srr 04.23.21
**************************************************************/

SELECT d.SpeciesCode AS Species, d.CurrentLocation,d.id, d.status, d.result AS "TcruziResult",
       min(d.TestDate) AS MinDate,max(d.TestDate) AS MaxDate,  count(*) TestCount
FROM
    (SELECT 'LabResults',
            b.id.demographics.species.arc_species_code.code AS SpeciesCode,
            b.id.curlocation.Room AS CurrentLocation,
            b.id,
            b.id.demographics.calculated_status AS status,
            b.date AS TestDate,
            b.runId.serviceRequested as panelName,
            b.serviceTestId.testName AS TestName,
            coalesce(b.runId, b.objectid) as runId,
         /*b.resultoorindicator,*/
            CASE b.qualresult
                WHEN 'NEGATIVE' THEN 'NEGATIVE'
                WHEN 'SERONEG' THEN 'NEGATIVE'
                WHEN 'POSITIVE' THEN 'POSITIVE'
                WHEN 'SEROPOS' THEN 'POSITIVE'
                WHEN 'IND' THEN 'INDETERMINATE'
                WHEN 'INDETERMINATE' THEN 'INDETERMINATE'
                END AS result
     FROM study.labworkResults b
     WHERE b.serviceTestId.includeInPanel = true and b.qcstate.publicdata = true and b.serviceTestid.ServiceId.Dataset = 'Surveillance'
       AND b.serviceTestId.testName LIKE '%CRUZI%'
       AND b.qualresult IN ('SEROPOS','POSITIVE')
       -- AND b.id.demographics.calculated_status  = 'Alive'
     union

     SELECT 'AssayResults',
            b.id.demographics.species.arc_species_code.code  AS SpeciesCode,
            b.id.curlocation.Room AS CurrentLocation,
            b.id,
            b.id.demographics.calculated_status AS status,
            b.date AS TestDate,
            b.runId.serviceRequested as panelName,
            b.serviceTestId.testName AS TestName,
            coalesce(b.runId, b.objectid) as runId,
         /*b.resultoorindicator,*/
            CASE b.qualresult
                WHEN 'NEGATIVE' THEN 'NEGATIVE'
                WHEN 'SERONEG' THEN 'NEGATIVE'
                WHEN 'POSITIVE' THEN 'POSITIVE'
                WHEN 'SEROPOS' THEN 'POSITIVE'
                WHEN 'IND' THEN 'INDETERMINATE'
                WHEN 'INDETERMINATE' THEN 'INDETERMINATE'
                END AS result

     FROM study.assay_labworkResults b
     WHERE b.serviceTestId.includeInPanel = true and b.qcstate.publicdata = true and b.serviceTestid.ServiceId.Dataset = 'Surveillance'
       AND b.serviceTestId.testName LIKE '%CRUZI%'
       AND b.qualresult IN ('SEROPOS','POSITIVE')
        --AND b.id.demographics.calculated_status  = 'Alive'
    ) AS d
    --WHERE result IN ('SEROPOS','POSITIVE')

/* d.SpeciesCode AS Species,d.CurrentLocation,d.id, d.status,'T cruzi', d.result*/
GROUP BY d.SpeciesCode,d.CurrentLocation,  d.id,d.status, d.result

ORDER BY min(d.TestDate) desc --, min(d.TestDate)