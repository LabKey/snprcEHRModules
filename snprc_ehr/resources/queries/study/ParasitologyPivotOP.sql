/*
 * Copyright (c) 2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/******************************************************************************
Ova & Parasite (O&P) result set.
srr 04.02.2019

******************************************************************************/

SELECT
  --p.runid,
  p.Id,
  p.date,
  p.serviceTestId.testName as TestName,
  --  p.runId.serviceRequested as PanelName,
  --p.TestName,
  GROUP_CONCAT(p.qualresult) as QResults

FROM study.labworkResults as p
       inner join snprc_ehr.labwork_panels as lt
                  on p.serviceTestid = lt.rowId
                    and lt.ServiceId.Dataset='Parasitology'

where p.id is not null
      --and p.runId.serviceRequested  in ('OVA & PARASITES' ) --,'OVA & PARASITES, URINE')
group by p.runid, p.Id, p.date,p.serviceTestId.testName--, p.runId.serviceRequested
  PIVOT QResults by TestName IN
  (select TestName from snprc_ehr.labwork_panels t
  where t.includeInPanel = true
  and t.ServiceId.Dataset = 'Parasitology'
  and t.ServiceId.ServiceName in ('OVA & PARASITES', 'OVA & PARASITES, URINE')

  )
;
