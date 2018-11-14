/*
 * Copyright (c) 2018 LabKey Corporation
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
  t1.id,
  t1.lsid,
  h3.room,
  h3.cage,
  CASE
  WHEN h3.cage IS NULL then h3.room
  ELSE (h3.room || ' / ' || h3.cage)
  END as location

FROM (
       SELECT
         h1.lsid,
         h1.id,
         max(h2.date) as prevDate
       FROM study.housing h1
         JOIN study.housing h2 ON (h2.id = h1.id AND h2.date < h1.date)

       GROUP BY h1.lsid , h1.id
     ) t1
  JOIN study.housing h3 ON (t1.id = h3.id AND t1.prevDate = h3.date
        AND h3.enddate = (select max(h4.enddate) from study.housing as h4 WHERE h4.id = t1.id))