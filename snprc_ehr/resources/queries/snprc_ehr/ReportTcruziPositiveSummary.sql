/**************************************************************
Purpose is to report summary data on T. cruzi tests.
Need to refactor out TestName and result to single values
of "T cruzi Test" and "Positive"
  srr 03.31.2021
Renamed to ReportTcruziPositiveSummary.sql
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
            CASE
                WHEN b.result IS NULL THEN  b.qualresult
                ELSE CAST(CAST(b.result AS float) AS VARCHAR)
                END as result
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
            CASE
                WHEN b.result IS NULL THEN b.qualresult
                ELSE CAST(CAST(b.result AS float) AS VARCHAR)
                END as result
     FROM study.assay_labworkResults b
     WHERE b.serviceTestId.includeInPanel = true and b.qcstate.publicdata = true and b.serviceTestid.ServiceId.Dataset = 'Surveillance'
       AND b.serviceTestId.testName LIKE '%CRUZI%'
       AND b.id.demographics.calculated_status  = 'Alive'
    ) AS d
WHERE result IN ('SEROPOS','POSITIVE')
GROUP BY d.speciesCode,d.CurrentLocation, d.id, d.TestName, d.result
ORDER BY min(d.TestDate)