SELECT
  b.packageId,
  b.name as pkg_name,
  b.pkgType,
  group_concat(b.description) as categories

FROM (
       select pcj.packageId,
         p.name,
         pc.description,
         p.pkgType
       from  snprc_ehr.package_category_junction pcj
       inner join snprc_ehr.package_category pc on pcj.categoryId = pc.id
       INNER JOIN snprc_ehr.package p on p.id = pcj.packageId
     ) b

GROUP BY b.packageId, b.name, b.pkgType