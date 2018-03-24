CREATE VIEW [labkey_etl].[v_snd_eventNotes] AS
-- ==========================================================================================
-- Author:		Binal Patel
-- Create date: 3/23/2018
-- Description:	View provides the datasource for event notes
-- Changes:
--
-- ==========================================================================================

SELECT
  animal_event_id AS eventId,
  proc_narrative  AS note,
  entry_date_tm   AS created,
  user_name       AS createdby,
  timestamp       AS timestamp
FROM dbo.PROC_NOTES
GO

GRANT SELECT ON labkey_etl.V_snd_EventNotes TO z_labkey;
GO