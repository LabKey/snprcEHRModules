-- noinspection SqlResolveForFile

/********************************************************
  Query will feed the export ETL back to CAMP.
      CampNewAnimalData


 srr 07.07.2020
 Syncing with current table structure
  srr 02.02.2021
 Adding SourceInstitution column to hold source institution for
  non-birth acquisitions.
  srr 03.31.2021
 Removed seconds from birth and acquisition
  srr 07.07.2021
 ********************************************************/

SELECT
    n.Id,
    timestampadd(SQL_TSI_SECOND, -second(n.BirthDate), n.BirthDate) AS BirthDate,
    n.BirthCode as Bd_Status,
    n.AcquisitionType,
    timestampadd(SQL_TSI_SECOND, -second(n.AcqDate), n.AcqDate) AS AcquisitionDate,
    n.SourceInstitutionLocation.code as SourceInstitutionLocation,
    n.species,
    n.Gender,
    n.sire,
    n.dam,
    n.Diet as DietInt,
    n.Diet.diet AS DietText,
    --CAST(diet AS INTEGER) AS DietTid,
    n.pedigree.name AS PedigreeText,
    n.pedigree AS PedigreeInt,
    --n.Colony AS ColonyInt, -- not in valid_colony
    n.Colony.Name AS ColonyText,
    n.AnimalAccount,
    --n.AnimalAccount.Account AS AccountText,
    --CAST(n.AnimalAccount AS INTEGER) AnimalAccountInt,
    --n.room, -- not in valid_locations
    n.IACUC,
    n.room.room,
    n.cage,
    n.OwnerInstitution,
    n.ResponsibleInstitution,
    n.Objectid,
    n.Modified,
    n.ModifiedBy,
    n.ModifiedBy.email AS ModifiedByEmail,
    n.Created,
    n.CreatedBy,
    n.CreatedBy.email AS CreatedByEmail,
    n.CreatedBy.displayname AS CreatedUserName,
    n.Container
FROM snprc_ehr.NewAnimalData n
