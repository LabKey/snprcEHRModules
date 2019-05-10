SELECT
  J.AnimalId,
  J.TimelineObjectId,
  T.TimelineId,
  T.StartDate,
  coalesce(J.EndDate, T.EndDate ) as EndDate

FROM snprc_scheduler.TimelineAnimalJunction as J
  INNER JOIN snprc_scheduler.Timeline as T on J.TimelineObjectId = T.ObjectId



