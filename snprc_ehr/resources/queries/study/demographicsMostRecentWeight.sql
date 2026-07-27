/*
 * Copyright (c) 2010-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
-- SNPRC override of ehr/queries/study/demographicsMostRecentWeight.sql.
--
-- Base module's version does `round(cast(AVG(w2.weight) as double), 2)`. Boundary values like 0.415
-- diverge between SQL Server and Postgres after the SS -> PG migration: the IEEE 754 nearest-double
-- to 0.415 is ~0.41499999999999998, and SS's ROUND on float truncates that to 0.41, while PG's
-- two-arg ROUND is defined only for NUMERIC, so LabKey SQL routes the round through NUMERIC on PG
-- where 0.415 stays exact and rounds half-away-from-zero to 0.42.
--
-- Rounding on NUMERIC(20, 4) on both databases removes the intermediate double representation,
-- so both engines evaluate ROUND(0.4150, 2) identically. Cast back to double at the end preserves
-- the column type advertised by demographicsMostRecentWeight.query.xml and its consumers.
SELECT

w.id,
w.MostRecentWeightDate,
timestampdiff('SQL_TSI_DAY', w.MostRecentWeightDate, now()) AS DaysSinceWeight,

null as weightField,
--NOTE: we need to be careful in case duplicate weights are entered on the same time
cast((
    SELECT round(cast(AVG(w2.weight) as NUMERIC(20, 4)), 2) AS _expr
    FROM study.weight w2
    WHERE w2.qcstate.publicdata = true AND w.id=w2.id AND w.MostRecentWeightDate=w2.date
) as double) AS MostRecentWeight

FROM (
SELECT
  w.Id AS Id,
  max(w.date) AS MostRecentWeightDate

FROM study.weight w
WHERE w.qcstate.publicdata = true and w.weight is not null
GROUP BY w.id
) w
