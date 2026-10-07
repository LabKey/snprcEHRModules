-- labwork_panels.TestName has inconsistent casing and whitespace, so this collapses spellings that differ only in case or spacing to one name; pivot column ids drop spaces, so such spellings would otherwise collide.
-- Joining on this computed key slows every pivot that uses it (about 30% on hematologyPivot); cleaning up the source test names would make it unnecessary.
SELECT
    UPPER(REPLACE(t.TestName, ' ', '')) AS TestKey,
    MIN(UPPER(RTRIM(LTRIM(t.TestName)))) AS TestName
FROM snprc_ehr.labwork_panels t
GROUP BY UPPER(REPLACE(t.TestName, ' ', ''))
