select project, protocol, coalesce(right(protocol, 2), 'ZZ') as species
from ehr.project
