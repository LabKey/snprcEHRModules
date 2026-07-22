SELECT
    SetName as LOOKUP_KEY,
    ObjectId as OBJECT_ID,
    LEFT(s.Email,
    CASE WHEN LOCATE('@', s.Email) = 0
    THEN LENGTH(s.Email)
    ELSE (LOCATE('@', s.Email) - 1) END) as USER_NAME,
    ls.Modified as ENTRY_DATE_TM
FROM
    snd.LookupSets ls
    INNER JOIN
    core.SiteUsers s
ON
    ls.ModifiedBy = s.UserId