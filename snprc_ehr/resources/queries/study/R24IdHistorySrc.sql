select i.id as AnimalId,
       i.date as date,
       i.value as id_value,
       i.id_type.description as id_type,
       i.source_name as source,
       i.objectid,
       i.modified
from study.idHistory as i
inner join study.demographics as d on i.id = d.id and d.species.arc_species_code = 'CJ'