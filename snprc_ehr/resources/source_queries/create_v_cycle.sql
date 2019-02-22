/**************************************
srr 02.07.2019
Wide table replacement for  deprecated OLDcreate_v_cycle.sql

***************************************/
USE [animal]
GO



alter VIEW [labkey_etl].[V_CYCLE] AS

SELECT  c.id                      			AS  Id,
        c.cycle_date              			AS  Date,
        c.observer_emp_num        			AS  ObserverEmp,
        c.cycle_location          			AS  CycleLocation,
        c.male_status             			AS  MaleStatus,
        c.male_id                 			AS  MaleId,
        c.tumescence_index        			AS  TumescenceIndex,
        c.vaginal_bleeding         			AS  VaginalBleeding,
        c.purple_color            			AS  PurpleColor,
        c.carrying_infant         			AS  CarryingInfant,
        c.object_id											AS objectid	,
        dbo.f_map_username(c.user_name)	AS modifiedby,
        c.entry_date_tm						AS modified,
        tc.created                			AS created,
  			tc.createdby              			AS createdby,
  			c.timestamp	
	FROM cycle c
		LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc 
  	ON tc.object_id = c.object_id
  	
 GO
 
 GRANT SELECT ON Labkey_etl.V_CYCLE TO z_labkey
	GO 