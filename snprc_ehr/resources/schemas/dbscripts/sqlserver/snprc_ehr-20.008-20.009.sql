/******************************************************
Change ValidDiet PK
Script generated by SSMS
srr 06.16.2020
******************************************************/
ALTER TABLE snprc_ehr.ValidDiet
    DROP CONSTRAINT PK_ValidDiet
    GO
ALTER TABLE snprc_ehr.ValidDiet ADD CONSTRAINT
    PK_ValidDiet PRIMARY KEY CLUSTERED
(
    Diet
)

GO
ALTER TABLE snprc_ehr.ValidDiet SET (LOCK_ESCALATION = TABLE)
GO