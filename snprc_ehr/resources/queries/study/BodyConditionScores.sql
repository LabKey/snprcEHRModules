
SELECT
    p.id as Id,
    p.date as BcsDate,
    p.procNarrative as BCS,
    case when substring(p.procNarrative, 7, 1) = ' ' then  cast(substring (p.procNarrative, 6,1) as float)
         else cast( substring (p.procNarrative, 6,3) as float )
         end as BCSValue,
    p.Created,
    p.CreatedBy,
    p.Modified,
    p.ModifiedBy

FROM study.procedure AS p
WHERE p.qcstate.publicdata = true
  AND p.pkgId.categories like '%BCS%'
  AND p.procNarrative <> 'BCS: error'
