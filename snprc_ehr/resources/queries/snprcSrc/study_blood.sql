select 
b.Id,
b.bleed_date_tm as date,
--TODO: consider special casing clinical, etc?
(SELECT project FROM ehr.project p WHERE p.name = b.reason) as project,
b.volume as quantity,
b."user_name" as performedby

from dbo.blood b
