SELECT
  c.category_code as category_code,
  c.description as description,
  c.comment as comment,
  c.displayable as displayable,
  c.species as species,
  c.sex as sex,
  c.enforce_exclusivity as enforce_exclusivity,
  c.allow_future_date as allow_future_date,
  c.sort_order as sort_order,
  c.modified as entry_date_tm,
  c.modifiedby.displayName as user_name,
  c.objectId as object_id
FROM animal_group_categories as c