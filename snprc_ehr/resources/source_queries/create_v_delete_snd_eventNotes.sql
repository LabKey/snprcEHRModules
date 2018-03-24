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