USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [labkey_etl].[v_package] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 10/23/2015
-- Description:	selects the pkgs data
-- Note:
--
-- Changes:
--
-- ==========================================================================================


SELECT pc.TID AS id,
	pc.pkg_id AS packageId,
	CAST(vct.code AS INT) AS categoryId,
	pc.user_name AS user_name,
	pc.entry_date_tm AS entry_date_tm,
	pc.object_id AS objectid,
	pc.timestamp AS timestamp
FROM dbo.PKG_CATEGORY AS pc
INNER JOIN valid_code_table AS vct ON pc.CATEGORY_CODE = vct.CODE 
				AND vct.TABLE_NAME = 'pkg_category'
				AND vct.COLUMN_NAME = 'category_code'
				AND vct.END_DATE_TM IS null


GO
grant SELECT on [labkey_etl].[v_package_category_junction] to z_labkey

go


SELECT * FROM labkey_etl.v_package_category_junction
SELECT * FROM labkey_etl.v_package_category