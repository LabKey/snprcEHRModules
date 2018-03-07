SELECT
  agm.id,
  agm.date,
  agm.groupId.name as colony

FROM study.animal_group_members as agm
  INNER JOIN snprc_ehr.animal_groups as ag ON ag.code = agm.groupId
  INNER JOIN snprc_ehr.animal_group_categories as agc on ag.category_code = agc.category_code and agc.description like '%colonies%'
WHERE agm.isActive = true and agm.qcstate.PublicData = true and id.demographics.calculated_status = 'Alive'