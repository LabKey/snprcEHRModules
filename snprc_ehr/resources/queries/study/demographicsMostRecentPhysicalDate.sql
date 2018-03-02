/*
* Copyright (c) 2013-2017 LabKey Corporation
*
* Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
*/

select
  d.Id,
  p2.lastDate as MostRecentPyhsicalDate,

  -- calculate PhyStatus (based on days since last physical)
  CASE WHEN d.calculated_status = 'Alive' THEN
    -- baboons
    CASE WHEN d.species.arc_species_code = 'PC' THEN
      CASE  WHEN d.id.age.ageInDays < 270 THEN 'OKAY'   -- baboon is less that 9 months old (too young to wean)
      ELSE
        CASE WHEN TIMESTAMPDIFF('SQL_TSI_DAY', (COALESCE (p2.lastDate, d.birth)), now ()) > 270 THEN 'Overdue' -- greater than 9 months
        ELSE
          CASE WHEN TIMESTAMPDIFF('SQL_TSI_DAY', (COALESCE (p2.lastDate, d.birth)), now ()) > 180 THEN 'Due' -- between 6 and 9 months
          ELSE 'Okay' -- less than 6 months
          END
        END
      END
    -- all species except baboons
    ELSE CASE WHEN TIMESTAMPDIFF('SQL_TSI_DAY', (COALESCE (p2.lastDate, d.birth)), now ()) > 270 THEN 'Overdue'
         ELSE CASE WHEN TIMESTAMPDIFF('SQL_TSI_DAY', (COALESCE (p2.lastDate, d.birth)), now ()) > 210 THEN 'Due'
              ELSE 'Okay'
              END
         END

    END
  ELSE
    NULL -- animal is not alive
  END     AS PhyStatus,



  CASE WHEN d.calculated_status = 'Alive' THEN TIMESTAMPDIFF('SQL_TSI_DAY',(COALESCE (p2.lastDate, d.birth)), now())
  ELSE NULL
  END AS DaysSinceLastPhysical,

  CASE WHEN d.calculated_status = 'Alive' THEN  (180 - TIMESTAMPDIFF('SQL_TSI_DAY', (COALESCE (p2.lastDate, d.birth)), now ()) )
  ELSE NULL
  END  AS DaysUntilDue,

  CASE WHEN d.calculated_status = 'Alive' THEN age_in_months(COALESCE (p2.lastDate, d.birth), now())
  ELSE NULL
  END AS MonthsSinceLastPhysical,

  CASE WHEN d.calculated_status = 'Alive' THEN  (6 - age_in_months(COALESCE (p2.lastDate, d.birth), now()))
  ELSE NULL
  END  AS MonthsUntilDue,

FROM study.demographics d

LEFT JOIN (

    select p.id, pcj.categoryId, max(p.date)as lastDate
    from study.procedure as p

    left join snprc_ehr.package_category_junction as pcj on pcj.packageId = p.pkgId
    inner join snprc_ehr.package_category as pc on pcj.categoryId = pc.id and lower(pc.description) = 'physical'

    WHERE p.qcstate.publicdata = true group by p.id, pcj.categoryId
  )
  as p2 ON (d.id = p2.id)