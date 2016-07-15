SELECT
  i1.Id,
  group_concat(DISTINCT i1.id_value) as idHistoryList

FROM (
SELECT
  i.Id,
  concat(concat( i.value, '/') ,i.id_type.description) as id_value

FROM study.idHistory i
where i.id_type.value not in ( 1, 30)


) i1

GROUP BY i1.Id