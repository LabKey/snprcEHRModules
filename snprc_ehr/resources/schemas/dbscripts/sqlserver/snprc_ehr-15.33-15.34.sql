
-- change primary key to species_code column

	UPDATE snprc_ehr.species set species_code = '' where species_code is NULL
	ALTER TABLE snprc_ehr.species ALTER COLUMN species_code NVARCHAR(3) NOT NULL

	UPDATE snprc_ehr.species set arc_species_code = '' where arc_species_code is NULL
	ALTER TABLE snprc_ehr.species ALTER COLUMN arc_species_code NVARCHAR(3)  NOT NULL

	ALTER TABLE snprc_ehr.species DROP CONSTRAINT pk_species
	ALTER TABLE snprc_ehr.species ADD CONSTRAINT pk_species PRIMARY KEY (species_code)



