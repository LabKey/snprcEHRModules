USE [animal]
GO

SET ANSI_NULLS ON
  GO

SET QUOTED_IDENTIFIER ON
  GO

/*==============================================================*/
/* View: v_vaccine data                                             */
/*==============================================================*/
Alter VIEW [labkey_etl].[v_vaccine] as
-- ====================================================================================================================
-- Object: v_vaccines
-- Author:		Scott Rouse
-- Create date: 02/14/2019
-- Note: sourced from v_vaccine
--
-- ==========================================================================================

SELECT v.ID 							AS Id,
       v.VACCINATION_DATE				AS Date,
       v.vaccine						AS Vaccine,
       v.PKG_ID							AS PkgId,
       v.PROC_ID						AS ProcId,
       v.OBJECT_ID						AS objectid,
       v.ENTRY_DATE_TM					AS modified,
       dbo.f_map_username(v.USER_NAME)	AS modifiedBy,
       tc.created						AS created,
       tc.createdby						AS createdby,
       v.TIMESTAMP


FROM dbo.V_VACCINE v
       INNER JOIN dbo.TAC_COLUMNS tc
                  ON tc.object_id = v.OBJECT_ID
