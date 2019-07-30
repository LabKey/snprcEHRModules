/********************************************************
Active Vet Query for  Grok.

Restricted to Active flagged vets only
Excludes vetId 2 which is (see paper records)

srr 07.30.2019
********************************************************/
select vv.displayName as VetName
from snprc_ehr.validVets vv
where vv.status = 'A'
and vv.vetId <> 2