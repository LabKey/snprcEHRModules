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
    b.Id,
    b.date,
    b.panelName,
    b.TestName,
    b.remark,
    MAX(b.result) as results
FROM culturePivotInner b

GROUP BY b.panelName, b.id, b.date, b.TestName, b.remark

    PIVOT results BY TestName IN

(select TestName from snprc_ehr.labwork_panels t
 where t.includeInPanel = true AND t.ServiceId.Dataset='Culture'
 order by t.TestName asc
)
