
CREATE VIEW [labkey_etl].[V_ANIMAL_OWNERSHIP] as
-- ====================================================================================================================
-- Object: v_animal_ownership
-- Author:		Terry Hawkins
-- Create date: 5/25/2016
--
-- ==========================================================================================


SELECT
a.id,
a.assign_date as date,
a.owner_institution_id as owner_institution,
a.institution_acquired_from_id as institution_acquired_from,
a.end_date as enddate,
a.object_id as objectid,
a.user_name as modifiedby,
a.entry_date_tm modified,
a.timestamp

from dbo.animal_ownership a
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = a.ID

go

grant SELECT on labkey_etl.V_ANIMAL_OWNERSHIP to z_labkey

go