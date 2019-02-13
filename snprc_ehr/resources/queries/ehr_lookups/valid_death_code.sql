select value,
       title,
       category,
       description,
       sort_order,
       date_disabled
from ehr_lookups.DispositionType
where Category = 'Death'