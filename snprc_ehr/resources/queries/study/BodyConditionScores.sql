SELECT
    p.id as Id,
    p.date as BcsDate,
    p.procNarrative as BCS,
    CAST (SUBSTRING(p.procNarrative, 6, CHARINDEX(' ', p.procNarrative,6) - 6) AS double) AS BCSValue,
    p.Created,
    p.CreatedBy,
    p.Modified,
    p.ModifiedBy
FROM study.procedure AS p
         INNER JOIN snprc_ehr.package_category_junction as pcj ON p.pkgId = pcj.packageId
         INNER JOIN snprc_ehr.package_category as pc ON pc.id = pcj.categoryId and pc.description like '%BCS%'
         INNER JOIN core.QCState as q ON p.qcstate = q.RowId and  q.Label = 'Completed'
WHERE p.procNarrative <> 'BCS: error'