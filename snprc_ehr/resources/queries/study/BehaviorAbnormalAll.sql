/****************************************************

  Emulates most of the behavior data on individual
  animals CAMP behavior tab.
  srr
Removed:
  bnc.AbnormalFlag:
    All are Y
  bnc.BehaviorId, bnc.NotificationStatus, bnc.CaseNumber:
    Just numbers.  W/O lookups not of much use
  bnc.SuspiciousBehavior:
    Need to confirm use w/ behavior only 2 Y from 2007/2008
  bnc.HousingType:
    An INT w/o lookup.  Will probably just bring in the lookup
    or get the data from Room if it is the same.
  bnc.BehaviorCategory, bnc.BehaviorComments:
    All rows are blank.  Serves no purpose.
  srr 04.22.20

****************************************************/
SELECT bn.Id,
       bn.NotificationNumber,
       bnc.NotificationDateTm,
       bn."date"   as ReportDate,
       bn.CloseDateTm,
       bn.Location AS Room,
       bnc.BehaviorId,
       bnc.Behavior,
       bnc.BehaviorDescription
FROM study.BehaviorNotification bn
         INNER JOIN snprc_ehr.BehaviorNotificationComment bnc
                    ON bn.NotificationNumber = bnc.NotificationNumber
--WHERE bn."date" > '1/1/2018'
order by bn.Id, bnc.NotificationDateTm, bn."date"
