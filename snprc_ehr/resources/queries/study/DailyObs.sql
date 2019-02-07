/***********************************
Daily observations reporting view.
Concats stool attributes to a single string value.



srr 02.05.2019
***********************************/
SELECT o.Id,
       o.date,
       o.Water,
       o.Feed,
       o.Comments,
       CASE
           WHEN o.SaNone = 'Y' THEN 'None'
           ELSE ''
       END + 
	   CASE
           WHEN o.SaUnknown = 'Y' THEN 'Unknown'
           ELSE ''
       END + 
	   CASE WHEN o.SaNormal = 'Y' THEN 'Normal'
           ELSE ''
       END + 
	   CASE WHEN o.SaSoft = 'Y' THEN ' Soft'
           ELSE ''
       END + 
	   CASE WHEN o.SaWatery = 'Y' THEN ' Watery'
            ELSE ''
       END +
	   CASE WHEN o.SaBloody = 'Y' THEN ' Bloody'
            ELSE ''
       END +
	   CASE WHEN o.SaDry = 'Y' THEN ' Dry'
            ELSE ''
       END +
	   CASE WHEN o.SaOther = 'Y' THEN ' Other'
            ELSE ''
       END +
	   CASE WHEN o.SaPellet = 'Y' THEN ' Pellet'
            ELSE ''
       END AS Stool,
       coalesce(o.HousingStatus.description,'NA') as Housing,
       o.taskid,
       o.requestid,
       o.modifiedby,
       --o.description,
       o.remark,
       o.history,
       o.QCState
FROM DailyObservations o;

/*
SELECT
  o.Id,
  o.date,
  o.Water,
  o.Feed,
  o.Comments,
  o.SaNormal,
  o.SaNone,
  o.SaBloody,
  o.SaDry,
  o.SaOther,
  o.SaPellet,
  o.SaSoft,
  o.SaUnknown,
  o.SaWatery,
  o.HousingStatus,
  o.taskid,
  o.requestid,
  o.performedby,
  o.description,
  o.remark,
  o.history,
  o.QCState
FROM DailyObservations o
*/