SELECT d.Id,
d.id.curLocation.room.area as area,
d.id.curLocation.room as Location,
d.gender,
d.species.arc_species_code,
d.calculated_status,
d.id.MostRecentTBDate.MostRecentTBDate,
d.id.MostRecentTBDate.MonthsSinceLastTB,
p.MostRecentPyhsicalDate,
case when d.id.MostRecentTBDate.MonthsSinceLastTB < 6  then 'Ok' when d.id.MostRecentTBDate.MonthsSinceLastTB between 6 and 7 then 'Due' else 'Overdue' end as status,

FROM demographics d
left join study.demographicsMostRecentPhysicalDate as p on p.id = d.id

where d.calculated_status = 'Alive'
and d.species.arc_species_code not in ('CJ', 'SM', 'RA', 'MD', 'RB', 'PT', 'CL')
and d.id.curLocation.room not in ('0.0', '100.01', '105.00', '35.02')
and d.id.curLocation.area not like  '27%'
and age_in_months(COALESCE (d.id.MostRecentTBDate.MostRecentTBDate, d.birth) , now()) >= 6
and age_in_months(COALESCE (p.MostRecentPyhsicalDate, d.birth) , now()) >= 6
order by d.id.curLocation.room asc, id asc
