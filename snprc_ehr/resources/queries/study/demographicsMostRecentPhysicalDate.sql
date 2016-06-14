select
  d.Id,
  p2.lastDate as MostRecentPyhsicalDate,
  case
    WHEN p2.lastDate IS NULL THEN 9999
    ELSE age_in_months(p2.lastDate, now())
  END AS MonthsSinceLastPhysical,

from study.demographics d

LEFT JOIN (select p.id, p.pkgId, max(p.date)as lastDate
  from study.procedure as p

  left join snprc_ehr.package_category_junction as pcj on pcj.packageId = p.pkgId
  inner join snprc_ehr.package_category as pc on pcj.categoryId = pc.id and lower(pc.description) = 'physical'

  WHERE p.qcstate.publicdata = true group by p.id, p.pkgId
  )
  as p2 ON (d.id = p2.id)