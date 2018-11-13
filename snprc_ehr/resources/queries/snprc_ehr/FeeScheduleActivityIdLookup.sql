SELECT
         fs.ActivityId,
         cast(fs.ActivityId as VARCHAR(5)) + ' - ' + fs.Description

FROM snprc_ehr.FeeSchedule AS fs
WHERE  fs.StartingYear = YEAR(NOW())
AND  fs.BudgetYear = YEAR(NOW())
AND fs.VersionLabel = 'Capped Fee Schedule'
AND fs.ActivityId between 4000 and 4999

order by ActivityId