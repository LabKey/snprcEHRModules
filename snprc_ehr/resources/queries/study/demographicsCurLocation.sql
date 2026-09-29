/*
 * Copyright (c) 2016-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
 /***********************************************
 Changed Location to display cage as int.
 i.e. 8.04-18.00 will not display as 8.04-18
 srr 01/25/19
  **********************************************/
SELECT d2.id,
       CASE
         WHEN d2.cage is null THEN d2.room
         WHEN isnumeric(d2.cage) = 1 THEN (d2.room || '-' || cast(cast(d2.cage as DECIMAL) as varchar) )
         ELSE (d2.room || '-' || d2.cage)
         END AS Location,
       d2.room.area, d2.room, d2.cage,
       ifdefined(d2.housingCondition) AS cond,
       d2.date, d2.reason, d2.remark,
       coalesce(d2.room, '')          AS room_order,
       d2.room_sortValue @hidden,
       coalesce(d2.cage, '')          AS cage_order,
       d2.cage_sortValue @hidden
FROM study.housing d2
WHERE d2.enddate IS NULL
  AND d2.qcstate.publicdata = true;