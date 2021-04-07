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
CREATE VIEW [labkey_etl].[v_delete_snd_eventData] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 2/20/2017
-- Description:	Selects the records to delete from snd.EventData dataset
-- Note:
--
-- Changes: Modified to use EventDataId as key (instead of ObjectId) (by Binal on Mar 23, 2018)
--
-- 3/23/2021 Deleting from the NarrativeCache requires the EventId. tjh
-- ==========================================================================================


SELECT
a.ANIMAL_EVENT_ID AS EventId,
a.PROC_ID as EventDataId,
a.audit_date_tm
FROM audit.audit_coded_procs AS a
WHERE a.audit_action = 'D'

GO

GRANT SELECT on labkey_etl.v_delete_snd_eventData to z_labkey
GRANT SELECT ON audit.audit_coded_procs TO z_labkey

go