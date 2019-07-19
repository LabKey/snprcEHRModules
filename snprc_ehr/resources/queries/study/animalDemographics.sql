SELECT
    d.id as id,
    d.gender as gender,
    d.id.MostRecentWeight.MostRecentWeight as weight,
    d.species.arc_species_code as species,
    d.id.curLocation.location as location,
    d.id.curLocation.room as room,
    d.id.curLocation.cage as cage,
    d.id.age.ageInYears as age,
    d.calculated_status as status
FROM study.demographics d
