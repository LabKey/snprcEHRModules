/*
 * Copyright (c) 2022-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
    b.Id,
    b.modified,
    b.Haplotype,
    b.Ocid,
    b.DataFileSource,
    group_concat(b.MhcValue) as MhcValue


FROM (
         SELECT
             b.Id,
             b.Haplotype,
             b.Ocid,
             b.MhcValue,
             b.DataFileSource,
             cast(b.modified as varchar) as modified
         FROM snprc_ehr.MhcData as b
     ) as b

GROUP BY b.id, b.ocid, b.DataFileSource, b.haplotype, b.modified

    PIVOT MhcValue BY Haplotype IN
(
    select distinct Haplotype from snprc_ehr.MhcData order by Haplotype
)