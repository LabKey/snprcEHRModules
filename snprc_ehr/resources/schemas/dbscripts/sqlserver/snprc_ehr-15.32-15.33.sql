/*
 * Copyright (c) 2015-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
