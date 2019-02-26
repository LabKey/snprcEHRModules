USE [animal]
GO

SET ANSI_NULLS ON
  GO

SET QUOTED_IDENTIFIER ON
  GO

/*==============================================================*/
/* View: v_blood_type data                                             */
/*==============================================================*/
create VIEW [labkey_etl].[v_blood_type] as
-- ====================================================================================================================
-- Object: v_blood_type
-- Author:		Scott Rouse
-- Create date: 02/14/2019
-- Note: sourced from v_vaccine
--
-- ==========================================================================================
SELECT bt.id				AS Id,
       bt.type_date			AS date,
       bt.blood_type		AS BloodType,
       bt.object_id			AS objectid,
	   bt.entry_date_tm					AS modified,
       dbo.f_map_username(bt.user_name)	AS modifiedBy,
	   tc.created						AS created,
       tc.createdby						AS createdby,
       bt.timestamp 
		FROM dbo.blood_type bt
		INNER JOIN dbo.TAC_COLUMNS tc
			ON tc.object_id = bt.object_id

 GO

GRANT SELECT ON Labkey_etl.V_blood_type TO z_labkey
  GO