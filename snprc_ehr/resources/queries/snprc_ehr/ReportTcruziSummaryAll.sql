
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

-- b.id is canonicalized with UPPER(LTRIM(RTRIM(...))) because the source has case-variant animal IDs
-- (e.g. 4x0133 vs 4X0133). SQL Server's case-insensitive collation grouped them together in the outer
-- GROUP BY; Postgres is case- and whitespace-sensitive so they'd split into separate groups without this normalization.
-- The b.qualresult, b.serviceTestid.ServiceId.Dataset, and b.serviceTestId.testName wraps in the WHERE
-- clauses exist for the same reason — SS matched their string filters case-insensitively; Postgres won't.
--
-- TestCount is count(*) over the inner UNION, so the dedup key is every column these subqueries
-- project — any free-text string in the projection can split a row that should collapse. The key is
-- therefore built on serviceTestId.TestId (the lab's test code), not serviceTestId.testName:
-- labwork_panels holds one TestId under more than one name spelling (e.g. TestId 136 as 'ALBUMIN' and
-- 'Albumin'), and on Postgres those spellings would count a single test twice.
--
-- Do NOT "fix" that by normalizing testName's case here. Distinct TestIds can share a name that
-- differs only in case — 850 is 'T. CRUZI AB' and 965 is 'T. Cruzi AB' — so folding the case merges
-- two different tests. That is exactly what SQL Server's case-insensitive collation did, and why it
-- undercounted animal 28215 (5) against Postgres (6, correct).
--
-- testName is no longer projected at all — TestId is the test's identity now. panelName stays in the
-- projection even though the outer query never selects it: it is a single-valued lookup off runId,
-- which is already in the key, so its spelling cannot split a row that runId would not have separated
-- anyway.
SELECT d.SpeciesCode AS Species, d.CurrentLocation,d.id, d.status, d.result AS "T cruzi result",
       min(d.TestDate) AS MinDate,max(d.TestDate) AS MaxDate,  count(*) TestCount
FROM
    (SELECT 'LabResults',
            b.id.demographics.species.arc_species_code.code AS SpeciesCode,
            b.id.curlocation.Room AS CurrentLocation,
            UPPER(LTRIM(RTRIM(b.id))) as id,
            b.id.demographics.calculated_status AS status,
            b.date AS TestDate,
            b.runId.serviceRequested as panelName,
            UPPER(LTRIM(RTRIM(b.serviceTestId.TestId))) AS TestId,
            coalesce(b.runId, b.objectid) as runId,
         /*b.resultoorindicator,*/
            CASE UPPER(LTRIM(RTRIM(b.qualresult)))
                WHEN 'NEGATIVE' THEN 'NEGATIVE'
                WHEN 'SERONEG' THEN 'NEGATIVE'
                WHEN 'POSITIVE' THEN 'POSITIVE'
                WHEN 'SEROPOS' THEN 'POSITIVE'
                WHEN 'IND' THEN 'INDETERMINATE'
                WHEN 'INDETERMINATE' THEN 'INDETERMINATE'
                END AS result
     FROM study.labworkResults b
     WHERE b.serviceTestId.includeInPanel = true and b.qcstate.publicdata = true and UPPER(LTRIM(RTRIM(b.serviceTestid.ServiceId.Dataset))) = 'SURVEILLANCE'
       AND UPPER(LTRIM(RTRIM(b.serviceTestId.testName))) LIKE '%CRUZI%'
       AND UPPER(LTRIM(RTRIM(b.qualresult))) IN ('SEROPOS','POSITIVE')
       -- AND b.id.demographics.calculated_status  = 'Alive'
     union

     SELECT 'AssayResults',
            b.id.demographics.species.arc_species_code.code  AS SpeciesCode,
            b.id.curlocation.Room AS CurrentLocation,
            UPPER(LTRIM(RTRIM(b.id))) as id,
            b.id.demographics.calculated_status AS status,
            b.date AS TestDate,
            b.runId.serviceRequested as panelName,
            UPPER(LTRIM(RTRIM(b.serviceTestId.TestId))) AS TestId,
            coalesce(b.runId, b.objectid) as runId,
         /*b.resultoorindicator,*/
            CASE UPPER(LTRIM(RTRIM(b.qualresult)))
                WHEN 'NEGATIVE' THEN 'NEGATIVE'
                WHEN 'SERONEG' THEN 'NEGATIVE'
                WHEN 'POSITIVE' THEN 'POSITIVE'
                WHEN 'SEROPOS' THEN 'POSITIVE'
                WHEN 'IND' THEN 'INDETERMINATE'
                WHEN 'INDETERMINATE' THEN 'INDETERMINATE'
                END AS result

     FROM study.assay_labworkResults b
     WHERE b.serviceTestId.includeInPanel = true and b.qcstate.publicdata = true and UPPER(LTRIM(RTRIM(b.serviceTestid.ServiceId.Dataset))) = 'SURVEILLANCE'
       AND UPPER(LTRIM(RTRIM(b.serviceTestId.testName))) LIKE '%CRUZI%'
       AND UPPER(LTRIM(RTRIM(b.qualresult))) IN ('SEROPOS','POSITIVE')
        --AND b.id.demographics.calculated_status  = 'Alive'
    ) AS d
    --WHERE result IN ('SEROPOS','POSITIVE')

/* d.SpeciesCode AS Species,d.CurrentLocation,d.id, d.status,'T cruzi', d.result*/
GROUP BY d.SpeciesCode,d.CurrentLocation,  d.id,d.status, d.result

ORDER BY min(d.TestDate) desc --, min(d.TestDate)