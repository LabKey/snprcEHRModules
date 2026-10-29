-- BehaviorAbnormalSummary
-- bn.Id is canonicalized with UPPER(LTRIM(RTRIM(...))) because the source has case-variant animal IDs
-- (e.g. 4x0133 vs 4X0133). SQL Server's case-insensitive collation grouped them together; Postgres
-- is case- and whitespace-sensitive so they'd split into separate groups without this normalization.
SELECT UPPER(LTRIM(RTRIM(bn.Id)))  as Id,
    --   bnc.BehaviorId   as BehaviorId,
       min(bn."date")   as FirstReported,
       max(bn."date")   as LastReported,
       bnc.Behavior     as Behavior,
       bnc.BehaviorDescription as BehaviorDesc,
       count(*)       as Incidents

FROM study.BehaviorNotification bn
         INNER JOIN snprc_ehr.BehaviorNotificationComment bnc
                    ON bn.NotificationNumber = bnc.NotificationNumber
group by UPPER(LTRIM(RTRIM(bn.Id))), bnc.BehaviorId, bnc.Behavior, bnc.BehaviorDescription
order by UPPER(LTRIM(RTRIM(bn.Id)))