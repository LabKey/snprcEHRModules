/********************************************************
Recent, active, admitting complaint  Query for  Grok.

Restricted to over 20 occurrences in the last two years.
Is free text.


srr 07.30.2019
********************************************************/

select AdmitComplaint
from study.cases c
where date > timestampadd('SQL_TSI_YEAR', -2,curdate())
group by admitcomplaint
having count(*) > 10