/*
 * Copyright (c) 2015-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  c.startingYear,
  c.VersionLabel,
  c.ActivityId,
  c.Description,
  c.Species,
  c.BudgetYear,
  Max(cost) as Cost
  --group_concat(cast(Cost as varchar)) as Cost

FROM (

       SELECT
         fs.StartingYear,
         fs.VersionLabel,
         fs.ActivityId,
         fs.Description,
         fs.ObjectId,
         fs.Species,
         fs.BudgetYear,
         fs.cost
       FROM snprc_ehr.FeeSchedule AS fs
      -- WHERE co.qcstate.publicdata = true
     ) c

GROUP BY c.StartingYear, c.VersionLabel, c.ActivityId, c.BudgetYear, Description, Species

PIVOT Cost BY BudgetYear IN
(select
distinct BudgetYear from snprc_ehr.FeeSchedule
order by BudgetYear)

order by StartingYear, VersionLabel, Species, ActivityId