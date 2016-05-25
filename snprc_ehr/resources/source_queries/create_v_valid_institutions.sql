CREATE VIEW [labkey_etl].[V_VALID_INSTITUTIONS] AS
-- ====================================================================================================================
-- Object: v_valid_institutions
-- Author:		Terry Hawkins
-- Create date: 5/25/2016
-- ==========================================================================================

SELECT vi.institution_id ,
       vi.institution_name ,
       vi.short_name ,
       vi.city ,
       vi.state ,
       vi.affiliate ,
       vi.web as web_site,
       vi.user_name as modifiedby,
       vi.entry_date_tm as modified,
       vi.object_id as objectid,
       vi.timestamp
	   FROM dbo.valid_institutions AS vi

GO

grant SELECT on labkey_etl.V_VALID_INSTITUTIONS to z_labkey

go