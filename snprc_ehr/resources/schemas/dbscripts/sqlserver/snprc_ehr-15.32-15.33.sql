
-- Use custom SNPRC species table instead of ehr_lookups.species

ALTER TABLE ehr_lookups.species DROP COLUMN species_code;
ALTER TABLE ehr_lookups.species DROP COLUMN arc_species_code;
ALTER TABLE ehr_lookups.species DROP COLUMN objectid;
ALTER TABLE ehr_lookups.species DROP COLUMN tid;

CREATE TABLE snprc_ehr.species
(
	common NVARCHAR(255) NOT NULL,
	scientific_name NVARCHAR(255),
	id_prefix NVARCHAR(255),
	mhc_prefix NVARCHAR(255),
	blood_per_kg FLOAT,
	max_draw_pct FLOAT,
	blood_draw_interval FLOAT,
	dateDisabled DATETIME NULL,
	cites_code NVARCHAR(200),
	species_code NVARCHAR(3),
	arc_species_code NVARCHAR(3),
	objectid NVARCHAR(4000),
	tid INT,
  CONSTRAINT pk_species PRIMARY KEY (common )
);
