/******************************************************************************
Non Ova & Parasite (O&P) result set.
srr 04.02.2019

******************************************************************************/
SELECT
  p.runid,
  p.Id,
  p.date,
  p.serviceTestId.testName as TestName,
  p.runId.serviceRequested as PanelName,
  --p.TestName,
  GROUP_CONCAT(p.qualresult) as QResults

FROM study.labworkResults as p
       inner join snprc_ehr.labwork_panels as lt
                  on p.serviceTestid = lt.rowId
                    and lt.ServiceId.Dataset='Parasitology'

where p.id is not null
  and p.runId.serviceRequested not in ('OVA & PARASITES','OVA & PARASITES, URINE')
group by p.runid, p.Id, p.date,p.serviceTestId.testName, p.runId.serviceRequested
  PIVOT QResults by TestName IN
  (select TestName from snprc_ehr.labwork_panels t
  where t.includeInPanel = true
  and t.ServiceId.Dataset = 'Parasitology'
  and t.ServiceId.ServiceName not in ('OVA & PARASITES','OVA & PARASITES, URINE')
  );
