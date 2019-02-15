USE [animal]
GO

SET ANSI_NULLS ON
  GO

SET QUOTED_IDENTIFIER ON
  GO

/*==============================================================*/
/* View: v_blood_type data                                             */
/*==============================================================*/
create VIEW [labkey_etl].[v_obscan] as
-- ====================================================================================================================
-- Object: v_obscan
-- Author:		Scott Rouse
-- Create date: 02/15/2019
-- Note:
--
-- ==========================================================================================
  SELECT o.scan_ref_num					AS ScanRefNum,
       o.id								AS Id,
       o.date_tm						AS date,
       o.reason							AS Reason,
       o.requestor_emp_num				AS RequestorEmpNum,
       o.sire_id						AS SireId,
       o.edc							AS EDC,
       o.adjusted						AS Adjusted,
       o.measured_fhr					AS MeasuredFHR,
       o.amt_amntc_fl					AS AmnioticFluidAmount,
       o.cond_amntc_fl					AS AmnioticFluidCondition,
       o.placenta_loc_fc				AS PlacentaLocFc,
       o.placenta_loc_ap				AS PlacentaLocAp,
       o.placenta_loc_lr				AS PlacentaLocLr,
       o.placenta_grade					AS PlacentaGrade,
       o.placenta_comment				AS PlacentaComment,
       o.measured_bpd					AS MeasuredBPD,
       o.bpd_age						AS BPDAge,
       o.measured_fod					AS MeasuredFOD,
       o.fod_age						AS FODAge,
       o.measured_hc					AS MeasuredFc,
       o.hc_age							AS HcAge,
       o.femur_len						AS FemurLen,
       o.femur_age						AS FemurAge,
       o.cycle_age						AS CycleAge,
       o.average_scan_age				AS AverageScanAge,
       o.scanner_emp_num				AS ScannerEmpNum,
       o.comment						AS comment,
	   o.object_id						AS objectid,
       dbo.f_map_username(o.user_name)	AS modifiedBy,
       tc.created						AS created,
       tc.createdby						AS createdby,
       o.timestamp
FROM dbo.obscan o
       INNER JOIN dbo.TAC_COLUMNS tc
                  ON tc.object_id = o.object_id

  GO

GRANT SELECT ON Labkey_etl.v_obscan TO z_labkey
  GO





       o.user_name,
       o.entry_date_tm,
       o.timestamp
	FROM dbo.obscan o


