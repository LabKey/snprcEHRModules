
ALTER VIEW [labkey_etl].[v_account_groups] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 2/12/2019
-- Description:	creates a distinct list of account groups to join with the valid_accounts table
-- Note:
--
-- Changes:
--
-- ==========================================================================================
SELECT DISTINCT COALESCE(va.account_group, 'Undefined') as value
FROM dbo.valid_accounts va
GO

grant SELECT on [labkey_etl].[v_account_groups] to z_labkey
go
