/*
 * Copyright (c) 2016 LabKey Corporation
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
SELECT
  d.participantid as animalId,
  ih.value as neprcId,
  d.birth,
  d.death,
  d.calculated_status.code as status,
  d.objectid,
  d.species.arc_species_code.code as species,
  -- Animals born at NEPRC and animals with both parents born at NEPRC
  -- have NEPRC as the sourceColony.  All others have SNPRC.
  CASE WHEN ih.id is NOT NULL then 'NEPRC'
	ELSE CASE WHEN  iDam.id IS NOT NULL AND iSire.id IS NOT null
			  THEN 'NEPRC'
    ELSE 'SNPRC' END
  END AS sourceColony,

  'SNPRC' as currentColony,
  d.gender.code as gender,
  d.dam,
  d.sire
FROM study.demographics d

-- is participant from NEPRC?
LEFT OUTER JOIN study.idhistory as ih on d.id = ih.id and ih.id_type in
	(select max(ii.id_type) from study.idhistory as ii where ii.id = ih.id
	and ih.id_type in (11, 28)) --NEPRC id types
-- is dam from NEPRC?
LEFT OUTER JOIN study.idhistory as iDam ON iDam.id = d.dam and iDam.id_type IN
		(select max(ii.id_type) from study.idhistory as ii where ii.id = iDam.id
					AND ii.id_type in (11, 28))
-- is sire from NEPRC?
LEFT OUTER JOIN study.idhistory as iSire ON iSire.id = d.sire and iSire.id_type IN
		(select max(ii.id_type) from study.idhistory as ii where ii.id = iSire.id
					AND ii.id_type in (11, 28))
where d.species.arc_species_code = 'CJ'
