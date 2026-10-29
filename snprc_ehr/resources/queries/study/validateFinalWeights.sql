/*
 * Copyright (c) 2011-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
-- SNPRC override of ehr/queries/study/validateFinalWeights.sql.
--
-- Base module's version calls timestampdiff('SQL_TSI_DAY', w.date, w.death) on raw timestamps.
-- BasePostgreSqlDialect.timestampdiff() special-cases SQL_TSI_SECOND, _MINUTE and _HOUR but
-- deliberately falls through to the JDBC driver for SQL_TSI_DAY (see its issue 25146 comment), so the
-- platforms disagree: the Microsoft driver emits DATEDIFF(day, ...), which counts calendar boundary
-- crossings and ignores time of day, while pgjdbc emits an epoch expression counting elapsed 24 hour
-- periods. A weight at 23:00 and a death seven calendar days later at 01:00 is 7 on SQL Server but 6 on
-- Postgres, so the >= 7 filter returned 6171 animals on SQL Server and 6140 on Postgres -- 31 animals
-- sitting within hours of the threshold.
--
-- Truncating both operands to midnight makes elapsed days and boundary crossings necessarily equal, so
-- both platforms return 6171. It also matches what the report means by "days": calendar days between the
-- last recorded weight and death, not hours elapsed.
--
-- The cast back to TIMESTAMP is required. Casting to DATE alone fails on Postgres, where date - date
-- yields an integer rather than an interval and pgjdbc's extract(epoch from ...) has no integer overload:
--   ERROR: function pg_catalog.extract(unknown, integer) does not exist
-- This is the same double cast used by ehr/queries/ehr_lookups/dateRange.sql.

select w.id, w.date as WeightDate, w.death, timestampdiff('SQL_TSI_DAY', CAST(CAST(w.date AS DATE) AS TIMESTAMP), CAST(CAST(w.death AS DATE) AS TIMESTAMP)) as daysBetween

from (SELECT
  w.Id AS Id, max(w.date) AS date, max(w.id.dataset.demographics.death) as death
	FROM study.weight w
	WHERE w.qcstate.publicdata = true and w.weight is not null and w.id.dataset.demographics.death is not null
	GROUP BY w.id) w
	where timestampdiff('SQL_TSI_DAY', CAST(CAST(w.date AS DATE) AS TIMESTAMP), CAST(CAST(w.death AS DATE) AS TIMESTAMP)) >= 7