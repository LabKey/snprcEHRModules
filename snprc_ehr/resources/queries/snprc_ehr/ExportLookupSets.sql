/************************************
Source for TAC/SND etl back to camp
  ETL: exportLookupSets.xml
srr 03.04.2021
 Added DisplayName to C/M by
  Columns Label and Description are null
srr 08.20.2021
************************************/
SELECT ls.LookupSetId,
       ls.SetName,
       ls.Label,
       ls.Description,
       ls.Container,
       ls.CreatedBy.DisplayName as CreatedByText,
       ls.Created,
       ls.ModifiedByDisplayName as ModifiedByText,
       ls.Modified,
       ls.Lsid,
       ls.ObjectId
FROM snd.LookupSets ls