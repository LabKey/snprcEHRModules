USE [animal]
GO

/****** Object:  View [labkey_etl].[V_PROTOCOLS]    Script Date: 4/8/2015 4:48:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/*==============================================================*/
/* View: V_PROTOCOLS                                               */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_PROTOCOLS] AS
-- ====================================================================================================================
-- Object: v_protocols
-- Author:		srouse
-- Create date: 04/08/2015
--
-- ==========================================================================================
/*********************************************************
ARC etl for labkey

Current protocols and protocols terminated after Jan 01, 2015
04.08.2015
Protocols that are active, or terminated after Jan 1, 2015:
	protocol defined as:
		Null arc_master_termination date or termination date after '1/1/2015'
		arc_detail.arc_num_amendment is the maximum amendment number that has a status of 'A', approved.
		arc_num is less than 9999.  Greater numbers are legacy or special case protocols.


**********************************************************/

SELECT m.tid, m.working_iacuc, d.title, d.approval_date, d.arc_num_amendment AS current_amendment, m.termination_date, m.object_id
      FROM dbo.arc_detail d
      INNER JOIN dbo.arc_master m
      ON m.arc_num_genus = d.arc_num_genus AND m.arc_num_seq = d.arc_num_seq
      WHERE d.application_status = 'A'
      AND d.arc_num_amendment = (SELECT MAX(z.arc_num_amendment) FROM dbo.arc_detail z 
									WHERE d.arc_num_seq = z.arc_num_seq
                                    AND d.arc_num_genus = z.arc_num_genus
                                    AND z.approval_date IS NOT NULL
                                    AND z.application_status = 'A')

	AND ISNULL(m.termination_date, GETDATE()) > '1/1/2015'  -- active protocols only
    AND m.arc_num_seq < 9999    -- 9999 and greater are historic or "NON SFBR"
	



GO



grant SELECT on labkey_etl.V_PROTOCOLS to z_labkey
go