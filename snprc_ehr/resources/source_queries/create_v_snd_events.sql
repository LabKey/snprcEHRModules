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
ALTER VIEW [labkey_etl].[v_snd_events] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 2/20/2018
-- Description:	View provides the datasource for ETLing animal event data into SND.Events table
-- Changes:
-- 09/15/2020 Removed leading spaces from ParticipantId
-- 9/22/2020 Removed coded_procs existence restriction on research/maintenance budgets and code clean up
-- ==========================================================================================

SELECT ae.ANIMAL_EVENT_ID AS EventId,
       LTRIM(ae.ANIMAL_ID) AS ParticipantId,
       CASE WHEN b1.budget_ID IS NOT NULL THEN b1.OBJECT_ID WHEN b2.BUDGET_ID IS NOT NULL THEN b2.OBJECT_ID ELSE b3.OBJECT_ID END AS parentObjectId,
       ae.EVENT_DATE_TM AS Date,
       ae.OBJECT_ID AS ObjectId,
       ae.ADMIT_ID AS AdmitId,
       ae.entry_date_tm                        AS modified,
       dbo.f_map_username(ae.user_name)        AS modifiedby,
       tc.created                             AS created,
       tc.createdby                           AS createdby,
       ae.timestamp                           AS timestamp

FROM dbo.ANIMAL_EVENTS AS ae
LEFT JOIN dbo.charge_account AS ca ON ca.charge_id = ae.CHARGE_ID
LEFT JOIN dbo.budgets AS b1 ON b1.CHARGE_ID = ae.CHARGE_ID AND ae.EVENT_DATE_TM BETWEEN b1.START_DATE_TM AND COALESCE(b1.END_DATE_TM, GETDATE()) -- research/maintenance budget
LEFT JOIN dbo.clinic AS cl ON ae.ADMIT_ID = cl.admit_id AND cl.admit_code = 1
LEFT JOIN dbo.BUDGETS AS b2 ON b2.CHARGE_ID = cl.charge_id AND ae.EVENT_DATE_TM BETWEEN b2.START_DATE_TM AND  COALESCE(b2.END_DATE_TM, GETDATE()) -- clinical budget
LEFT JOIN dbo.BUDGETS AS b3 ON b3.BUDGET_ID = 0 -- legacy budget

-- get created and createdBy columns
LEFT JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = ae.object_id

-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ae.animal_id

GO

GRANT SELECT ON Labkey_etl.v_snd_events TO z_labkey
GO
