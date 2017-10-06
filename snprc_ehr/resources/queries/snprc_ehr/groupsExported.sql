SELECT
  g.code as code,
  g.category_code as category_code,
  g.date as start_date,
  g.enddate as end_date,
  g.name as description,
  g.comment as comment,
  g.sort_order as sort_order,
  g.modified as entry_date_tm,
  g.modifiedby.displayName as user_name,
  g.objectId as object_id
FROM animal_groups as g