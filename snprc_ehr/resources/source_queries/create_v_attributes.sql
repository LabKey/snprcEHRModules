USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*==============================================================*/
/* View: V_ATTRIBUTES                                    */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_ATTRIBUTES] as
-- ====================================================================================================================
-- Object: v_attributes
-- Author:		Terry Hawkins
-- Create date: 12/30/2015
--
-- ==========================================================================================

SELECT a.id ,
	   a.entry_date_tm AS date,
     NULL AS flag,
	   a.attribute AS attribute,
     a.comment AS remark,
	   a.object_id AS objectId,
     a.user_name ,
     a.timestamp  FROM dbo.attributes AS a
---- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = a.id


go

grant SELECT on labkey_etl.V_ATTRIBUTES to z_labkey

go