/*
 * Copyright (c) 2023-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
    SetName as LOOKUP_KEY,
    ObjectId as OBJECT_ID,
    LEFT(s.Email,
    CASE WHEN charindex('@', s.Email) = 0
    THEN LEN(s.Email)
    ELSE (charindex('@', s.Email) - 1) END) as USER_NAME,
    ls.Modified as ENTRY_DATE_TM
FROM
    snd.LookupSets ls
    INNER JOIN
    core.SiteUsers s
ON
    ls.ModifiedBy = s.UserId