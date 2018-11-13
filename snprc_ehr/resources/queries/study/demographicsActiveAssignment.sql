/*
 * Copyright (c) 2013-2015 LabKey Corporation
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
  a.id,
  group_concat(DISTINCT a.protocolString, chr(10)) as protocolAndInvestigator,
  group_concat(DISTINCT a.protocolDisplayName, chr(10)) as protocols,
  group_concat(DISTINCT cast(a.investigator as varchar), chr(10)) as investigators,
  group_concat(DISTINCT cast(a.protocolTitle as varchar)) as protocolTitles,
  COALESCE(count(distinct a.protocolDisplayName), 0) as totalProtocols,
  COALESCE(count(a.lsid), 0) as numActiveAssignments

FROM (

SELECT
  d.id,
  a.protocol.displayName as protocolDisplayName,
  a.protocol.inves as investigator,
  a.protocol.title as protocolTitle,
  a.lsid,
  cast(CASE
    WHEN a.protocol.inves IS NOT NULL THEN (a.protocol.inves || ' [' || a.protocol.displayName || ']')
    ELSE a.protocol.displayName
  END as varchar(500)) as protocolString

FROM study.demographics d
LEFT JOIN study.assignment a ON (a.id = d.id AND a.isActive = true)

) a

GROUP BY a.id