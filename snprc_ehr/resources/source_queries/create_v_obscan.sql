/*
 * Copyright (c) 2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
USE [animal]
GO

SET ANSI_NULLS ON
  GO

SET QUOTED_IDENTIFIER ON
  GO

/*==============================================================*/
/* View: v_blood_type data                                             */
/*==============================================================*/
ALTER VIEW [labkey_etl].[v_obscan] as
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
       o.measured_fhr					AS MeasuredFetalHR,
       o.amt_amntc_fl					AS AmnioticFluidAmount,
       o.cond_amntc_fl					AS AmnioticFluidCondition,
       o.placenta_loc_fc				AS PlacentaLocFC,
       o.placenta_loc_ap				AS PlacentaLocAP,
       o.placenta_loc_lr				AS PlacentaLocLR,
       o.placenta_grade					AS PlacentaGrade,
       o.placenta_comment				AS PlacentaComment,
       o.measured_bpd					AS MeasuredBPD,
       o.bpd_age						AS BPDAge,
       o.measured_fod					AS MeasuredFOD,
       o.fod_age						AS FODAge,
       o.measured_hc					AS MeasuredHC,
       o.hc_age							AS HCAge,
       o.femur_len						AS FemurLength,
       o.femur_age						AS FemurAge,
       o.cycle_age						AS CycleAge,
       o.average_scan_age				AS AverageScanAge,
       o.scanner_emp_num				AS ScannerEmpNum,
       o.comment						AS Comment,
	   o.object_id						AS objectid,
	   o.entry_date_tm					AS modified,
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





   