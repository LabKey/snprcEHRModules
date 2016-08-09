SELECT
  agm.id,
  agm.date,
  agm.groupId.name as pedigree

FROM study.animal_group_members as agm
INNER JOIN ehr.animal_groups ag ON (ag.RowId = agm.GroupId AND ag.Category = 'Pedigree')
WHERE agm.isActive = true and agm.qcstate.PublicData = true
