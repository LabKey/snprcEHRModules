CREATE VIEW [labkey_etl].[v_delete_snd_events] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 2/20/2017
-- Description:	Selects the records to delete from snd.Events dataset
-- Note:
--
-- Changes:
--
-- ==========================================================================================


SELECT a.object_id,
  a.audit_date_tm
FROM audit.audit_animal_events AS a
WHERE a.audit_action = 'D' AND a.OBJECT_ID IS NOT NULL

GO

GRANT SELECT on labkey_etl.v_delete_snd_events to z_labkey
GRANT SELECT ON audit.audit_animal_events TO z_labkey

go
