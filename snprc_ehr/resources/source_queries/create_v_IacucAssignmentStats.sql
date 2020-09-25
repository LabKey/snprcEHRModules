CREATE VIEW labkey_etl.v_IacucAssignmentStats as
    -- ====================================================================================================================
-- Object: v_IacucAssignmentStats
-- Author: Terry Hawkins
-- Create date: 9/25/2020
-- Note: Tracks numbers of animals allowed and assigned to IACUC protocols
--
-- ========================================================================== ================

SELECT
       t.[3yr_period] AS ThreeYearPeriod,
       t.working_iacuc AS WorkingIacuc,
       t.arc_num_seq AS ArcNumSeq,
       t.arc_num_genus AS ArcNumGenus,
       t.first_amendment AS FirstAmendment,
       t.last_amendment AS LastAmendment,
       t.start_date AS StartDate,
       t.end_date AS EndDate,
       dbo.f_IACUC_num_animals_approved(t.working_iacuc, COALESCE(t.end_date, GETDATE())) AS NumAnimalsAllowed,
       dbo.f_IACUC_num_animals_assigned(t.working_iacuc, COALESCE(t.end_date, GETDATE())) AS NumAnimalsAssigned

FROM [dbo].[v_IACUC_3yr_periods] AS t
go

GRANT SELECT ON labkey_etl.v_IacucAssignmentStats TO z_labkey;
go
