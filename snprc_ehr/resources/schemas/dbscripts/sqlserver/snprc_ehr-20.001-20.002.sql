ALTER TABLE snprc_ehr.ValidChargeBySpecies ADD startDate DATETIME NOT NULL DEFAULT GETDATE();
ALTER TABLE snprc_ehr.ValidChargeBySpecies ADD stopDate DATETIME;
