
-- TODO: source table needs a species column to designate
SELECT a.accountGroup AS AccountGroup,
       a.account AS Account,
       a.date AS StartDate,
       a.description AS Description,
       a.account + ' - ' + rtrim(a.description) as DisplayValue

FROM snprc_ehr.validAccounts AS a
where enddate is null and a.account <> '0000-000-00'
ORDER BY StartDate desc
