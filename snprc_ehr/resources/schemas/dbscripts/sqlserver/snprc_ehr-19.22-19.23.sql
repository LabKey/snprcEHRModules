
-- adding species to the PK
ALTER TABLE snprc_ehr.ValidChargeBySpecies
    DROP CONSTRAINT PK_snprc_ValidChargeBySpecies
GO

ALTER TABLE snprc_ehr.ValidChargeBySpecies ADD CONSTRAINT
    PK_snprc_ValidChargeBySpecies PRIMARY KEY CLUSTERED
(
    Project,
    Species
)

GO