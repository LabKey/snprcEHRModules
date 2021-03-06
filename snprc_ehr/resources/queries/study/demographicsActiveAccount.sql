/*
 * Copyright (c) 2015-2018 LabKey Corporation
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
SELECT
  d.id,
  a.date,
  GROUP_CONCAT(a.account) as account,
  GROUP_CONCAT(cast(cast(a.date as date) as varchar(12))) as accountDate,
  GROUP_CONCAT(a.account) as accountOnly,
  GROUP_CONCAT(va.accountGroup) as accountGroup,
  GROUP_CONCAT(va.description) as accountDescription
FROM study.demographics d
  INNER JOIN study.animalAccounts a ON a.id = d.id AND a.isActive = true
  LEFT OUTER JOIN snprc_ehr.validAccounts va ON va.account = a.account

GROUP BY d.id, a.date