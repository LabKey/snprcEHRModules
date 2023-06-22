SELECT
    SetName as LOOKUP_KEY,
    ObjectId as OBJECT_ID,
    LEFT(p.Name,
    CASE WHEN charindex('@', p.Name) = 0
    THEN LEN(p.Name)
    ELSE (charindex('@', p.Name) - 1) END) as USER_NAME,
    Modified as ENTRY_DATE_TM
FROM
    snd.LookupSets ls
    INNER JOIN
    core.Principals p
ON
    ls.ModifiedBy = p.UserId