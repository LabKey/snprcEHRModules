/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
-- BehaviorAbnormalSummary
SELECT bn.Id            as Id,
    --   bnc.BehaviorId   as BehaviorId,
       min(bn."date")   as FirstReported,
       max(bn."date")   as LastReported,
       bnc.Behavior     as Behavior,
       bnc.BehaviorDescription as BehaviorDesc,
       count(*)       as Incidents

FROM study.BehaviorNotification bn
         INNER JOIN snprc_ehr.BehaviorNotificationComment bnc
                    ON bn.NotificationNumber = bnc.NotificationNumber
group by bn.Id, bnc.BehaviorId, bnc.Behavior, bnc.BehaviorDescription
order by bn.Id