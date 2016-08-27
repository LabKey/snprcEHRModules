select w.id as AnimalId,
       w.date,
       w.weight,
       w.objectid,
       w.modified
from study.weight as w
inner join study.demographics as d on w.id = d.id and d.species.arc_species_code = 'CJ'