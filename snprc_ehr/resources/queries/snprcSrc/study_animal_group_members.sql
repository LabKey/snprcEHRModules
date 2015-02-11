select
b.id,
b.start_date as date,
b.end_date as enddate,

--TODO: how do we ensure the order in which these are populated??
(SELECT a.rowid FROM labkey_trunk.ehr.animal_groups a WHERE a.name = CAST(bg.breeding_grp as varchar)) as groupId,
b."user_name" as performedby
from breeding_grp b
left join dbo.valid_breeding_grps bg ON (b.breeding_grp = bg.breeding_grp)

