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
CREATE VIEW [labkey_etl].[v_delete_snd_eventNotes] AS
-- ==========================================================================================
-- Author:		Binal Patel
-- Create date: 3/23/2018
-- Description:	Selects records to delete from snd.EventNotes
-- Note:
--
-- Changes:
--
-- ==========================================================================================

SELECT
  a.animal_event_id as EventId,
  a.audit_date_tm
FROM audit.audit_proc_notes AS a
WHERE a.audit_action = 'D'
GO

GRANT SELECT on labkey_etl.v_delete_snd_EventNotes to z_labkey
GRANT SELECT ON audit.audit_proc_notes TO z_labkey
GO