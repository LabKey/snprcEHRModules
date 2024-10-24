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
    p.Id,
    p.date,
    p.remark,
    p.testName,
    p.panelName,
    GROUP_CONCAT(p.result) as result,
    GROUP_CONCAT(p.abnormal_flags) as abnormal_flags

FROM ParasitologyPivotInner p
WHERE p.panelName in ('OVA & PARASITES','OVA & PARASITES, URINE')

GROUP BY p.id, p.date, p.remark, p.panelName, p.TestName
    PIVOT result, abnormal_flags BY TestName IN
(select TestName from snprc_ehr.labwork_panels t
where t.includeInPanel = true AND t.ServiceId.Dataset='Parasitology'
   and t.ServiceId.ServiceName in ('OVA & PARASITES','OVA & PARASITES, URINE')
)
