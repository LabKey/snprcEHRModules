
CREATE VIEW [labkey_etl].[V_FLAG_VALUES] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 3/28/2016
-- Description:	Used as source for the flag_values ETL
-- Note:
--
-- Changes:
--
-- ==========================================================================================

SELECT f.category ,
       f.value ,
       f.code ,
       f.description ,
       f.objectid ,
       f.datedisabled,
       f.entry_date_tm,
       f.timestamp
FROM labkey_etl.flag_values AS f


GO
grant SELECT on [labkey_etl].[v_flag_values] to z_labkey

go

