USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [labkey_etl].[v_package_category] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 10/23/2015
-- Description:	selects the package_category data for labkey from the valid_code_table
-- Note:
--
-- Changes:
--
-- ==========================================================================================


SELECT CAST(vct.code AS INT) AS id,
	vct.code AS name,
	vct.DESCRIPTION AS description,
	vct.user_name AS user_name,
	vct.entry_date_tm AS entry_date_tm,
	vct.object_id AS objectid,
	vct.timestamp AS timestamp
FROM dbo.valid_code_table AS vct
WHERE vct.TABLE_NAME = 'pkg_category'
  AND vct.COLUMN_NAME = 'category_code'
  AND vct.END_DATE_TM IS null


GO
grant SELECT on [labkey_etl].[v_package_category] to z_labkey

go

