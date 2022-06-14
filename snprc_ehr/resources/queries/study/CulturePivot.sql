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
Non Ova & Parasite (O&P) result set.
srr 04.02.2019

******************************************************************************/
SELECT
    p.runid,
    p.Id,
    p.date,
    p.serviceTestId.testName as TestName,
    p.runId.serviceRequested as PanelName,
    p.remark,
    GROUP_CONCAT(p.qualresult) as QResults

FROM study.labworkResults as p
         inner join snprc_ehr.labwork_panels as lt
                    on p.serviceTestid = lt.rowId
                        and lt.ServiceId.Dataset='Culture'

where p.id is not null
  group by p.runid, p.Id, p.date,p.serviceTestId.testName, p.remark, p.runId.serviceRequested
    PIVOT   QResults by TestName IN
  (select  t.testName from snprc_ehr.labwork_panels t
  where t.includeInPanel = true
  and t.ServiceId.Dataset = 'Culture'
  order by t.TestName asc
  );
