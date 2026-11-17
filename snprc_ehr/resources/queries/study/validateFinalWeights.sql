/*
 * Copyright (c) 2011-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
-- SNPRC override of ehr/queries/study/validateFinalWeights.sql: age_in_days counts calendar days on both databases, where timestampdiff('SQL_TSI_DAY') counts elapsed 24-hour periods on Postgres.

select w.id, w.date as WeightDate, w.death, age_in_days(w.date, w.death) as daysBetween

from (SELECT
  w.Id AS Id, max(w.date) AS date, max(w.id.dataset.demographics.death) as death
	FROM study.weight w
	WHERE w.qcstate.publicdata = true and w.weight is not null and w.id.dataset.demographics.death is not null
	GROUP BY w.id) w
	where age_in_days(w.date, w.death) >= 7