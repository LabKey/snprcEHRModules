/************************
NULL columns exported to CAMP
SortOrder
Lsid
Added DisplayName to CreatedBy and ModifiedBy
  srr 08.19.2021
************************/

SELECT l.LookupSetId,
       l.Value,
       l.Displayable,
       l.SortOrder,
       l.Container,
       l.CreatedBy.DisplayName as CreatedByText,
       l.Created,
       l.ModifiedBy.DisplayName as ModifiedByText,
       l.Modified,
       l.Lsid,
       l.LookupId,
       l.ObjectId
FROM snd.Lookups l