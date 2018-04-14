SELECT
  b.packageId,
  b.name as pkg_name,
  group_concat(b.description) as categories

FROM (
       select pcj.packageId,
         p.name,
         pc.description
       from  snprc_ehr.package_category_junction pcj
       inner join snprc_ehr.package_category pc on pcj.categoryId = pc.id
       INNER JOIN snprc_ehr.package p on p.id = pcj.packageId
     ) b

GROUP BY b.packageId, b.name