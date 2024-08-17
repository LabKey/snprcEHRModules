SELECT
    d.Id,
    d.gender,
    d.species.arc_species_code.Common_name as species,
    d.species.arc_species_code as breed,
    d.birth as birthDate,
    d.death as deathDate,
    case when d.calculated_status.code = 'Dead' then 'Y' when d.calculated_status.code = 'Alive' then 'N' else Null end as isDeceased,
    d.dam,
    d.sire,
    d.objectId,
    d.modifiedBy.DisplayName as modifiedBy,
    d.modified
FROM demographics as d
where len(d.id) <= 6