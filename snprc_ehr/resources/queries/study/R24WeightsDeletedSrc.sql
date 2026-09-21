/*
 * Copyright (c) 2017-2018 LabKey Corporation
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
select
  -- LOCATE is case-sensitive on Postgres and the audit record map's key casing is not guaranteed,
  -- so search a lower-cased copy. lower() preserves length, so the offset stays valid for
  -- substring() on the original.
  substring(dae.oldrecordmap, LOCATE('objectid=', lower(dae.oldrecordmap)) + LENGTH('objectid='), 36) as objectid,
  dae.date as modified

from auditLog.DatasetAuditEvent as dae

WHERE dae.comment = 'A dataset record was deleted'
      -- The dataset is named 'weight' in lower case. Postgres compares this exactly, so the previous
      -- 'Weight' matched nothing and the query returned no rows; SQL Server matches either spelling.
      and datasetid.name = 'weight'