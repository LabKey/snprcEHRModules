/*
Provides U24 account assignments for MCC collaboration
*/
SELECT a.Id as AnimalId,
       a.id.demographics.species,
       a.date,
       a.account,
       COALESCE(a.enddate, id.demographics.death) AS enddate,
       CASE WHEN a.account = '4876-001-00' THEN 'U24 Breeder'
            WHEN a.account = '3508-402-12' THEN 'U24 Offspring'
            ELSE 'Other' END AS Assignment,
       a._key as objectid,
       a.created,
       a.createdBy,
       a.modifiedBy,
       COALESCE(a.modified, a.id.demographics.modified) as modified,
       greatest (a.modified, a.id.demographics.modified) AS timestamp
FROM animalAccounts as a
where a.id.demographics.species = 'CTJ'
