SELECT
a.id as id,
a.protocol as protocol,
case when a.date >= p.startdate then a.date else p.startdate end as assignment_date,
p.project as project,
p.shortname,
--case when COALESCE (a.enddate, p.enddate) is NULL then true else false end  as isActive
a.isActive



FROM study.assignment as a
inner join ehr.project as p on a.protocol = p.protocol