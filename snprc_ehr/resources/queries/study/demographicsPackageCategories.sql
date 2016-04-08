SELECT DISTINCT
  d.id,
  pcj.categoryId as categoryId

FROM study.demographics d
INNER JOIN study.procedure pr ON pr.id = d.id
INNER JOIN snprc_ehr.package_category_junction pcj ON pcj.packageid = pr.pkgID
