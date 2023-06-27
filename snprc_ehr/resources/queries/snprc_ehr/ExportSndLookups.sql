SELECT
    LookupId as LOOKUP_ID,
    ls.SetName as LOOKUP_KEY,
    Value as VALUE,
    CASE
        WHEN l.Displayable = 0 THEN 'Y'
        WHEN l.Displayable = 1 THEN 'N'
    END as IS_HIDDEN,
    l.SortOrder as ORDER_NUM,
    l.ObjectId as OBJECT_ID,
    'N' as DEFAULT_FLAG,
    LEFT(p.Name,
	CASE WHEN charindex('@', p.Name) = 0
	THEN LEN(p.Name)
	ELSE (charindex('@', p.Name) - 1) END) as USER_NAME,
    l.Modified as ENTRY_DATE_TM
FROM
    snd.Lookups l
INNER JOIN
    snd.LookupSets ls
ON
    l.LookupSetId = ls.LookupSetId
INNER JOIN
    core.Principals p
ON
    l.modifiedBy = p.UserId