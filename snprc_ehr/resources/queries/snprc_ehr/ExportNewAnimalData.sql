-- noinspection SqlResolveForFile

/********************************************************
  Query will feed the export ETL back to CAMP.
      CampNewAnimalData


 srr 07.07.2020
 ********************************************************/

SELECT
    n.Id,
    n.BirthDate,
    n.BirthCode as Bd_Status,
    n.AcquisitionType,
    n.AcqDate AS AcquisitionDate,
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
    n.CreatedBy.displayname AS CreatedUserName

FROM snprc_ehr.NewAnimalData n
