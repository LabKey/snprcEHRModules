SELECT a.value as AcqCode,
       a.category as Category,
       rtrim(a.value) + ' - ' + a.description as DisplayValue,
       a.sort_order as SortOrder
from ehr_lookups.AcquisitionType as a