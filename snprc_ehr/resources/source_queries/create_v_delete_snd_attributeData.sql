CREATE VIEW [labkey_etl].[v_delete_snd_attributeData] AS
-- ==========================================================================================
-- Author:		Binal Patel
-- Create date: 3/23/2018
-- Description:	Selects records to delete from exp.ObjectProperty
-- Note:
--
-- Changes:
--
-- ==========================================================================================

SELECT
  CONCAT (a.proc_id,'-',a.attrib_key) as EventDataAndName,
  a.audit_date_tm
FROM audit.audit_coded_proc_attribs AS a
WHERE a.audit_action = 'D'
GO

GRANT SELECT on labkey_etl.v_delete_snd_AttributeData to z_labkey
GRANT SELECT ON audit.audit_coded_proc_attribs TO z_labkey
GO