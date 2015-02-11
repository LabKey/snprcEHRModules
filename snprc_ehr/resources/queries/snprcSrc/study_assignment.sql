select
a.Id,
a.start_date as date,
a.end_date as enddate,
--TODO: resolve into ehr.project PK
--m.rowid
a.arc_num_seq,
a.arc_num_genus,
a.status,
--a.working_iacuc,
a."user_name" as performedBy,
a.comments as remark,

from dbo.arc_animal_assignments a
left join dbo.arc_master m on (a.arc_num_seq = m.arc_num_seq AND a.arc_num_genus = m.arc_num_genus)

