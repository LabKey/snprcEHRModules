SELECT
    LookupId as LOOKUP_ID,
    ls.SetName as LOOKUP_KEY,
    Value as VALUE,
    CASE
        WHEN l.Displayable = false THEN 'Y' ELSE 'N' END as IS_HIDDEN,
    l.SortOrder as ORDER_NUM,
    l.ObjectId as OBJECT_ID,
    'N' as DEFAULT_FLAG,
    LEFT(s.Email,
	CASE WHEN LOCATE('@', s.Email) = 0
	THEN LENGTH(s.Email)
	ELSE (LOCATE('@', s.Email) - 1) END) as USER_NAME,
    l.Modified as ENTRY_DATE_TM
FROM
    snd.Lookups l
INNER JOIN
    snd.LookupSets ls
ON
    l.LookupSetId = ls.LookupSetId
INNER JOIN
    core.SiteUsers s
ON
    l.modifiedBy = s.UserId