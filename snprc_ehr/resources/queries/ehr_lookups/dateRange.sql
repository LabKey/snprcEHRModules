/*
 * Copyright (c) 2011-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
-- SNPRC override of ehr/queries/ehr_lookups/dateRange.sql.
--
-- week() is a passthrough, so WeekOfYear was ISO 8601 on Postgres and US numbering on SQL Server -- a one week shift for most of any year whose Jan 1 falls Fri-Sun.
-- weekus() pins it to the SQL Server numbering SNPRC reconciles against.
--
-- Scoped to snprc_ehr so other centres' Postgres values do not move.
PARAMETERS(StartDate TIMESTAMP, NumDays INTEGER DEFAULT 30)

SELECT
i.date,
CAST(i.date as date) as dateOnly,
cast(dayofyear(i.date) as integer) as DayOfYear,
cast(dayofmonth(i.date) as integer) as DayOfMonth,
cast(dayofweek(i.date) as integer) as DayOfWeek,
ceiling(cast(dayofmonth(i.date) as float) / 7.0) as WeekOfMonth,
cast(weekus(i.date) as integer) as WeekOfYear,
CAST(StartDate AS TIMESTAMP) as startDate @hidden,
cast(NumDays as integer) as numDays @hidden

FROM (SELECT

timestampadd('SQL_TSI_DAY', i.value, CAST(COALESCE(CAST(StartDate as date), curdate()) AS TIMESTAMP)) as date

FROM ldk.integers i

WHERE i.value < NumDays) i
