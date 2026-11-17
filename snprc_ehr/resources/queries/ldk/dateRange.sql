/*
 * Copyright (c) 2010-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
-- SNPRC override of LDK/queries/ldk/dateRange.sql, for the reason given in this module's ehr_lookups/dateRange.sql.
PARAMETERS(StartDate TIMESTAMP, EndDate TIMESTAMP)

SELECT
i.date,
CAST(i.date as date) as dateOnly,
cast(dayofyear(i.date) as integer) as DayOfYear,
cast(dayofmonth(i.date) as integer) as DayOfMonth,
cast(dayofweek(i.date) as integer) as DayOfWeek,
ceiling(cast(dayofmonth(i.date) as float) / 7.0) as WeekOfMonth,
cast(weekus(i.date) as integer) as WeekOfYear,
CAST(StartDate AS TIMESTAMP) as startDate @hidden,
cast(EndDate as TIMESTAMP) as endDate @hidden

FROM (SELECT

timestampadd('SQL_TSI_DAY', i.value, CAST(COALESCE(StartDate, curdate()) AS TIMESTAMP)) as date

FROM ldk.integers i

) i

WHERE i.date <= EndDate
