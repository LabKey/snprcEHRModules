SELECT
  d.id,
  a.date,
  a.account as account,
  va.accountGroup as accountGroup
FROM study.demographics d
  INNER JOIN study.animalAccounts a ON a.id = d.id AND a.isActive = true
  LEFT OUTER JOIN snprc_ehr.validAccounts va ON va.account = a.account