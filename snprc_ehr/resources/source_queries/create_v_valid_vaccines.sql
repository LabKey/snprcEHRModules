USE [animal]
GO

CREATE VIEW [labkey_etl].[v_valid_vaccines] AS
-- ====================================================================================================================
-- Object: v_valid_vaccine
-- Author:		Scott Rouse
-- Create date: 07/19/2019
-- Changes:
--
-- ==========================================================================================

SELECT vv.vaccine                       AS Vaccine,
       vv.object_id                     AS objectid,
       vv.entry_date_tm                 AS modified,
       dbo.f_map_username(vv.user_name) AS modifiedby,
       tc.created                       AS created,
       tc.createdby                     AS createdby,
       vv.timestamp
FROM dbo.valid_vaccines AS vv
         LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = vv.object_id
    GO

GRANT SELECT ON labkey_etl.v_valid_vaccines TO z_labkey
    GO