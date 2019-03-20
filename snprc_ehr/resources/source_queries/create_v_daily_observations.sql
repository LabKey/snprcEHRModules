USE [animal]
GO

SET ANSI_NULLS ON
  GO

SET QUOTED_IDENTIFIER ON
  GO

/*==============================================================*/
/* View: v_observations                                             */
/*==============================================================*/
CREATE VIEW [labkey_etl].[v_daily_observations] as
-- ====================================================================================================================
-- Object: v_daily_observations
-- Author:		Scott Rouse
-- Create date: 01/29/2019
-- Note: sourced from v_accounts
-- srr 02/04/2019 set to TitleCase
-- ==========================================================================================
SELECT o.id as Id,
       o.obs_date as date,
       o.water AS Water,
       o.feed AS Feed,
       o.comments AS Comments,
       o.sa_none AS SaNone,
       o.sa_bloody AS SaBloody,
       o.sa_dry AS SaDry,
       o.sa_loose AS SaLoose,
       o.sa_normal AS SaNormal,
       o.sa_other AS SaOther,
       o.sa_pellet AS SaPellet,
       o.sa_soft AS SaSoft,
       o.sa_unknown AS SaUnknown,
       o.sa_watery AS SaWatery,
       o.housing_status AS HousingStatus,
       o.tid,
       o.object_id as objectid,
       o.entry_date_tm as modified,
       dbo.f_map_username(o.user_name) as modifiedBy,
       tc.created as created,
       tc.createdby as createdby,
       o.timestamp
FROM dbo.observations o
            LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = o.object_id
       -- select primates only from the TxBiomed colony
            INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = o.ID

  go

grant SELECT on labkey_etl.V_DAILY_OBSERVATIONS to z_labkey

  go