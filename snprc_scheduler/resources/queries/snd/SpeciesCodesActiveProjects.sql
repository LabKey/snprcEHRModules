-- List Species code (2char) and common name for
-- Active primate projects

select distinct s.arc_species_code,  ps.species.common_name
from snprc_ehr.species s
         inner join ehr.projectSpecies ps
                on  ps.species = s.arc_species_code
         inner join snd.Projects p
                 on p.referenceID = ps.project
where  p.Active = True and s.primate  ='Y'