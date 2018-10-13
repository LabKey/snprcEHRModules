select agm.groupid, max(agm.enddate) as enddate
from study.animal_group_members as agm
group by groupid