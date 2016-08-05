
/****** Object:  View [labkey_etl].[v_clinical_admissions]    Script Date: 8/14/2015 8:08:46 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [labkey_etl].[v_valid_vets] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 8/5/2016
-- Description:	Selects the valid vets
-- Note:
--
--
-- ==========================================================================================


SELECT v.tid AS vetId,
	   v.vet_name AS displayName,
	   v.email_address as emailAddress,
	   case when v.status = 'A' then 'Active' else 'Inactive' end AS status,
	   v.user_name AS user_name,
	   v.entry_date_tm AS entry_date_tm,
	   v.object_id AS objectid,
	   v.timestamp AS timestamp



FROM dbo.valid_vet AS v

GO


grant SELECT on [labkey_etl].[v_valid_vets] to z_labkey

go
