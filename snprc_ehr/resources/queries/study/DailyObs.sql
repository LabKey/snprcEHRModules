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
/***********************************
Daily observations reporting view.
Concats stool attributes to a single string value.



srr 02.05.2019
***********************************/
SELECT o.Id,
       o.date,
       o.Water,
       o.Feed,
       o.Comments,
       CASE
           WHEN o.SaNone = 'Y' THEN 'None'
           ELSE ''
       END +
	   CASE
           WHEN o.SaUnknown = 'Y' THEN 'Unknown'
           ELSE ''
       END +
	   CASE WHEN o.SaNormal = 'Y' THEN 'Normal'
           ELSE ''
       END +
       CASE WHEN o.SaLoose = 'Y' THEN ' Loose'
                  ELSE ''
       END +
       CASE WHEN o.SaSoft = 'Y' THEN ' Soft'
           ELSE ''
       END +
	   CASE WHEN o.SaWatery = 'Y' THEN ' Watery'
            ELSE ''
       END +
	   CASE WHEN o.SaBloody = 'Y' THEN ' Bloody'
            ELSE ''
       END +
	   CASE WHEN o.SaDry = 'Y' THEN ' Dry'
            ELSE ''
       END +
	   CASE WHEN o.SaOther = 'Y' THEN ' Other'
            ELSE ''
       END +
	   CASE WHEN o.SaPellet = 'Y' THEN ' Pellet'
            ELSE ''
       END AS Stool,
       coalesce(o.HousingStatus.description,'NA') as Housing,
       o.taskid,
       o.requestid,
       o.modifiedby,
       --o.description,
       o.remark,
       o.history,
       o.QCState
FROM DailyObservations o;

/*
SELECT
  o.Id,
  o.date,
  o.Water,
  o.Feed,
  o.Comments,
  o.SaNormal,
  o.SaNone,
  o.SaBloody,
  o.SaDry,
  o.SaOther,
  o.SaPellet,
  o.SaSoft,
  o.SaUnknown,
  o.SaWatery,
  o.HousingStatus,
  o.taskid,
  o.requestid,
  o.performedby,
  o.description,
  o.remark,
  o.history,
  o.QCState
FROM DailyObservations o
*/
