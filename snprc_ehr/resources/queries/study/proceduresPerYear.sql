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

--  NOTE - SNPRC is not yet populating ProcedureId. Re-add those parts of the query when available
-- Id is uppercased so case-variant animal IDs group together: 132 animals have records under both
-- '4X####' and '4x####', which SQL Server's case-insensitive collation merged and Postgres does not.
-- Stopgap for this report only; the underlying dataset rows still need to be normalized.

SELECT
UPPER(c.Id) as Id,
CAST('01-01-' || cast(year(c.date) as varchar) as date) as date,
CAST('12-31-' || cast(year(c.date) as varchar) as date) as enddate,
year(c.date) as year,
-- group_concat(distinct c.procedureid.category) as category,
-- c.procedureid.shortName as procedureName,
count(*) as total

FROM study."Animal Procedures" c
-- WHERE c.procedureid IS NOT NULL
GROUP BY
  UPPER(c.Id),
--   c.procedureid.shortName,
  year(c.date)