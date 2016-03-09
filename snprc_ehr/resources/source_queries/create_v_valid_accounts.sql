USE [animal]
GO

ALTER VIEW [labkey_etl].[V_VALID_ACCOUNTS] AS
-- ====================================================================================================================
-- Object: v_valid_acocunts
-- Author:		Terry Hawkins
-- Create date: 3/3/2016
-- ==========================================================================================

SELECT va.account,
	   va.status as accountStatus,
	   va.ori_date AS date,
	   va.close_date AS enddate,
	   CASE WHEN va.description IS NULL THEN 'Description is missing' ELSE va.description END AS description,
	   CASE WHEN va.account_group IS NULL THEN 'Undefined' ELSE va.account_group END  AS accountGroup,
       va.object_id AS objectid,
	   va.user_name AS userName,
	   va.entry_date_tm AS entryDateTm,
       va.timestamp
	   FROM dbo.valid_accounts AS va

GO


grant SELECT on labkey_etl.V_VALID_ACCOUNTS to z_labkey

go