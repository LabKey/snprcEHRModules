SELECT
  d.id as animalId,
  d.birth,
  d.death,
  d.calculated_status.code as status,
  d.objectid,
  d.species.arc_species_code.code as species,
  'SNPRC' as sourceColony,
  d.gender.code as gender,
  d.dam,
  d.sire
FROM study.demographics d
where species.arc_species_code = 'CJ'
