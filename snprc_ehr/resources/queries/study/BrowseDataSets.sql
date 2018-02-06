select 'study' as Schema,
    categoryId.label as CategoryId,
    Label as Label,
    Name as name,
    ShowByDefault as ShowByDefault,
    true as isAnimal
from study.datasets
UNION
  select 'study' as schema, 'ClinPath' as CategoryId,'Surveillance Results' as Label, 'surveillancePivot' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'snprc_ehr' as schema, 'Misc' as CategoryId,'Fee Schedule' as Label, 'FeeSchedulePivot' as Name,  true as ShowByDefault, false as isAnimal
UNION
select 'ehr_lookups' as schema, 'Lookup Tables' as CategoryId,'Lookup sets' as Label, 'lookup_sets' as Name,  true as ShowByDefault, false as isAnimal
UNION
select 'snprc_ehr' as schema, 'Misc' as CategoryId,'Valid Charge by Species' as Label, 'ValidChargeBySpecies' as Name,  true as ShowByDefault, false as isAnimal
UNION
select 'study' as schema, 'Colony Management' as CategoryId,'Animal Accounts & Groups' as Label, 'ActiveAccountsWithGroup' as Name,  true as ShowByDefault, true as isAnimal