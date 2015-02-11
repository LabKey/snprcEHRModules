select
s.surgery_id as Id,
s.surgery_date_tm as date,
(SELECT project FROM ehr.project p WHERE p.name = s.working_iacuc) as project,
s.description as title,
s.surgeon_name as performedby
--TODO:
--admit_id?
--surgery_level

from dbo.surgeries s

UNION ALL

select
e.Id,
e.exam_date as date,
null as project,
e.exam_type as title,
e."user_name" as performedby

from dbo.exams e