/*
 * Copyright (c) 2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
-- SNPRC override of the ehr module's ehr_lookups.lab_test_units.
--
-- units is canonicalized with UPPER(LTRIM(RTRIM(...))) because the SNPRC source data has case/whitespace
-- variants of the same unit (e.g. 'mg' vs 'MG'). SQL Server's case-insensitive collation collapsed these
-- on DISTINCT; Postgres is case- and whitespace-sensitive and would return the variants as separate rows.
--
-- Scoped to snprc_ehr rather than changed in the shared ehr module.
SELECT
  DISTINCT UPPER(LTRIM(RTRIM(units))) as units

FROM ehr_lookups.lab_tests
WHERE units IS NOT NULL and units != ''
