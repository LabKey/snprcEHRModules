
CREATE VIEW [labkey_etl].[V_REMARKS] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 5/23/2016
-- Description:	Used as source for the notes dataset ETL
-- Note:
--
-- Changes:
--
-- ==========================================================================================

SELECT r.ID AS id,
	r.remark_date AS date,
	r.remark as remark,
	r.OBJECT_ID AS objectid,
	r.entry_date_tm AS modified,
	r.user_name AS modifyedby,
	r.TIMESTAMP
FROM dbo.remarks AS r
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS v ON v.id = r.id

GO

GRANT SELECT ON labkey_etl.v_remarks TO z_labkey
GO

