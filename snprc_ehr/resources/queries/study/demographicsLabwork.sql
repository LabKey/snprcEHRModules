/*
 * Copyright (c) 2015-2018 LabKey Corporation
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
  d.id,
  max(CASE WHEN h.servicerequested = 'CBC with DIFF' THEN h.date ELSE null END) as lastHematologyDate,
  max(CASE WHEN h.servicerequested = 'CHEM PROFILE' THEN h.date ELSE null END) as lastBiochemistryDate

FROM study.demographics d
LEFT JOIN study.clinpathRuns h ON (d.id = h.id AND (h.servicerequested = 'CBC with DIFF' OR h.servicerequested = 'CHEM PROFILE'))
WHERE d.calculated_status = 'Alive'
GROUP BY d.id

