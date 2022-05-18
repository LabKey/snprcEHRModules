SELECT
    b.Id,
    b.Haplotype,
    b.Ocid,
    b.DataFileSource,
    b.modified,
    group_concat(b.MhcValue) as MhcValue

FROM (
         SELECT
             b.Id,
             b.Haplotype,
             b.Ocid,
             b.MhcValue,
             b.DataFileSource,
             b.Modified
         FROM snprc_ehr.MhcData as b
         ) as b

GROUP BY b.id, b.ocid, b.DataFileSource, b.haplotype, b.modified

PIVOT MhcValue BY Haplotype IN
(select distinct Haplotype from snprc_ehr.MhcData order by Haplotype

)
