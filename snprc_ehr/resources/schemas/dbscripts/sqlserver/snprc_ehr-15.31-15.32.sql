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

-- Alters existing ehr_lookups.species table to include additional SNPRC species code columns columns needed
-- for ETLs (objectid)

CREATE PROCEDURE snprc_ehr.handleUpgrade AS
    BEGIN
    IF NOT EXISTS(SELECT column_name
            FROM information_schema.columns
            WHERE table_name='species' and table_schema='ehr_lookups' and column_name='objectid')
        BEGIN
        -- Run variants of scripts from trunk

						ALTER TABLE ehr_lookups.species ADD species_code nvarchar(3);
						ALTER TABLE ehr_lookups.species ADD arc_species_code nvarchar(3);
						--ALTER TABLE ehr_lookups.species ADD arc_common_name nvarchar(255);
						--ALTER TABLE ehr_lookups.species ADD arc_scientific_name nvarchar(255);
						ALTER TABLE ehr_lookups.species ADD objectid nvarchar(4000);
						ALTER TABLE ehr_lookups.species ADD tid int;
        END
    END;

GO

EXEC snprc_ehr.handleUpgrade
GO

DROP PROCEDURE snprc_ehr.handleUpgrade
GO

