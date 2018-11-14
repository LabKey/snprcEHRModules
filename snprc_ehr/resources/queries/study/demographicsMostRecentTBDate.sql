/*
 * Copyright (c) 2015-2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

 --NOTE: this is joined to demographics such that animals never tested for TB
 --will still get a value for MonthsSinceLastTB
 -- Animals that are not alive will get NULL results.
 --Animals never tested will use birthdate as last tb date. tjh
select
  d.Id,
  T2.lastDate as MostRecentTBDate,

  -- calculate TbStatus (based on days since last tb test)
  CASE WHEN d.calculated_status = 'Alive' THEN
    -- baboons
    CASE WHEN d.species.arc_species_code = 'PC' THEN
         CASE  WHEN d.id.age.ageInDays < 270 THEN 'OKAY'   -- baboon is less that 9 months old (too young to wean)
          ELSE
            CASE WHEN TIMESTAMPDIFF('SQL_TSI_DAY', (COALESCE (T2.lastDate, d.birth)), now ()) > 270 THEN 'Overdue' -- greater than 9 months
                ELSE
                  CASE WHEN TIMESTAMPDIFF('SQL_TSI_DAY', (COALESCE (T2.lastDate, d.birth)), now ()) > 180 THEN 'Due' -- between 6 and 9 months
                    ELSE 'Okay' -- less than 6 months
                  END
            END
          END
      -- all species except baboons
      ELSE CASE WHEN TIMESTAMPDIFF('SQL_TSI_DAY', (COALESCE (T2.lastDate, d.birth)), now ()) > 270 THEN 'Overdue'
           ELSE CASE WHEN TIMESTAMPDIFF('SQL_TSI_DAY', (COALESCE (T2.lastDate, d.birth)), now ()) > 210 THEN 'Due'
               ELSE 'Okay'
                 END
           END

    END
  ELSE
    NULL -- animal is not alive
  END     AS TbStatus,

  CASE WHEN d.calculated_status = 'Alive' THEN TIMESTAMPDIFF('SQL_TSI_DAY',(COALESCE (T2.lastDate, d.birth)), now())
  ELSE NULL
  END AS DaysSinceLastTB,

  CASE WHEN d.calculated_status = 'Alive' THEN  (180 - TIMESTAMPDIFF('SQL_TSI_DAY', (COALESCE (T2.lastDate, d.birth)), now ()) )
  ELSE NULL
  END  AS DaysUntilDue,

  CASE WHEN d.calculated_status = 'Alive' THEN age_in_months(COALESCE (T2.lastDate, d.birth), now())
  ELSE NULL
  END AS MonthsSinceLastTB,

  CASE WHEN d.calculated_status = 'Alive' THEN  (6 - age_in_months(COALESCE (T2.lastDate, d.birth), now()))
  ELSE NULL
  END  AS MonthsUntilDue,

  CASE WHEN d.calculated_status = 'Alive' THEN  (select group_concat(tb.site) as eyeTested FROM study.tb tb WHERE tb.id = d.id and tb.date = T2.lastdate)
  ELSE NULL
  END AS SiteTested

from study.demographics d

LEFT JOIN (select tb.id, max(tb.date) as lastDate
    from study.tb as tb
    inner join study.demographics as d on d.id = tb.id
    WHERE tb.qcstate.publicdata = true group by tb.id) T2
ON (d.id = t2.id)



