/**************************************************************
Sourced from ReportTcruziPositiveSummary
  Purpose is to report all summary data on T. cruzi tests.

  Changed to CASE to report single value for result (i.e. combining seroPos and Positive)
  Runs as expected in SQLdbx.
  srr 04.16.2021
**************************************************************/

SELECT d.SpeciesCode AS Species,d.CurrentLocation,d.id, d.TestName, d.result, min(d.TestDate) AS MinDate,max(d.TestDate) AS MaxDate,  count(*) TestCount
FROM
    (SELECT 'LabResults',
            b.id.demographics.species.arc_species_code.code AS SpeciesCode,
            b.id.curlocation.Room AS CurrentLocation,
            b.id,
            b.date AS TestDate,
            b.runId.serviceRequested as panelName,
            b.serviceTestId.testName AS TestName,
            coalesce(b.runId, b.objectid) as runId,
            b.resultoorindicator,
            CASE b.qualresult
                WHEN 'NEGATIVE' THEN 'NEGATIVE'
                WHEN 'SERONEG' THEN 'NEGATIVE'
                WHEN 'POSITIVE' THEN 'POSITIVE'
                WHEN 'SEROPOS' THEN 'POSITIVE'
                END AS result
     FROM study.labworkResults b
     WHERE b.serviceTestId.includeInPanel = true and b.qcstate.publicdata = true and b.serviceTestid.ServiceId.Dataset = 'Surveillance'
       AND b.serviceTestId.testName LIKE '%CRUZI%'
       AND b.id.demographics.calculated_status  = 'Alive'
     union

     SELECT 'AssayResults',
            b.id.demographics.species.arc_species_code.code  AS SpeciesCode,
            b.id.curlocation.Room AS CurrentLocation,
            b.id,
            b.date AS TestDate,
            b.runId.serviceRequested as panelName,
            b.serviceTestId.testName AS TestName,
            coalesce(b.runId, b.objectid) as runId,
            b.resultoorindicator,
            CASE b.qualresult
                WHEN 'NEGATIVE' THEN 'NEGATIVE'
                WHEN 'SERONEG' THEN 'NEGATIVE'
                WHEN 'POSITIVE' THEN 'POSITIVE'
                WHEN 'SEROPOS' THEN 'POSITIVE'
                END AS result

     FROM study.assay_labworkResults b
     WHERE b.serviceTestId.includeInPanel = true and b.qcstate.publicdata = true and b.serviceTestid.ServiceId.Dataset = 'Surveillance'
       AND b.serviceTestId.testName LIKE '%CRUZI%'
       AND b.id.demographics.calculated_status  = 'Alive'
    ) AS d
    --WHERE result IN ('SEROPOS','POSITIVE')
GROUP BY d.speciesCode,d.CurrentLocation, d.id, d.TestName, d.result
ORDER BY d.id, min(d.TestDate)