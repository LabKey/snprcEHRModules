SELECT d.id, sire.id AS Parent_Id, 'Sire' AS Relationship,
sire.calculated_status, a.totalOffspring.TotalOffspring as totalOffspring
FROM study.demographics AS d
LEFT JOIN study.demographics AS sire ON sire.id = d.sire
LEFT JOIN study.animal as a on a.id = sire.id

UNION all

SELECT d.id, dam.id AS Parent_Id, 'Dam' AS Relationship,
dam.calculated_status, a.totalOffspring.TotalOffspring as totalOffspring
FROM study.demographics AS d
LEFT JOIN study.demographics AS dam ON dam.id = d.dam
LEFT JOIN study.animal as a on a.id = dam.id
