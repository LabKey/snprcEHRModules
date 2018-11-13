SELECT ag.*
FROM snprc_ehr.animal_groups AS ag
  INNER JOIN snprc_ehr.animal_group_categories AS agc ON ag.category_code = agc.category_code
WHERE agc.description LIKE '%baboon colonies%' and ag.enddate is null