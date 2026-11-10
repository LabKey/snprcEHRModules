/* Integer-typed view of the biocontainment_responsiveness lookup set, so it matches the integer dataset columns in study.BiocontainmentObservations */
SELECT CAST(l.value AS INTEGER) AS value,
       l.description,
       l.sort_order,
       l.date_disabled
FROM ehr_lookups.biocontainment_responsiveness l
