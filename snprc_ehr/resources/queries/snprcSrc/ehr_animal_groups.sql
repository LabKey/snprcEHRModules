select
cast(b.breeding_grp AS varchar) AS name,
b.ori_date as date,
b.description as comment

from dbo.valid_breeding_grps b