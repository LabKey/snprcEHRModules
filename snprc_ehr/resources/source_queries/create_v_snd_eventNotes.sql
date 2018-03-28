ALTER VIEW [labkey_etl].[v_snd_eventNotes] AS
-- ==========================================================================================
-- Author:		Binal Patel
-- Create date: 3/23/2018
-- Description:	View provides the datasource for event notes
-- Changes: 3/28/2018 - Joined with v_demographics to limit the result set to the animal data being exported to LK. tjh
--
-- ==========================================================================================

SELECT
  pn.animal_event_id AS eventId,
  pn.proc_narrative  AS note,
  pn.entry_date_tm                        AS modified,
  dbo.f_map_username(pn.user_name)        AS modifiedby,
  tc.created                             AS created,
  tc.createdby                           AS createdby,
  pn.timestamp                           AS timestamp
  
FROM dbo.PROC_NOTES AS pn
-- get created and createdBy columns        
LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = pn.object_id
-- get animal id
INNER JOIN dbo.animal_events AS ae ON ae.ANIMAL_EVENT_ID = pn.ANIMAL_EVENT_ID
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ae.animal_id

GO

GRANT SELECT ON labkey_etl.V_snd_EventNotes TO z_labkey;
GO