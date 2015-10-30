USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [labkey_etl].[v_package] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 10/23/2015
-- Description:	selects the pkgs data
-- Note:
--
-- Changes:
--
-- ==========================================================================================


SELECT p.PKG_ID AS id,
	LEFT(p.DESCRIPTION, 100) AS name,
	p.NARRATIVE AS descriptiong,
	p.user_name AS user_name,
	p.entry_date_tm AS entry_date_tm,
	p.object_id AS objectid,
	p.timestamp AS timestamp
FROM dbo.PKGS AS p


GO
grant SELECT on [labkey_etl].[v_package] to z_labkey

go

