/*
 * Copyright (c) 2016-2018 LabKey Corporation
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
 -- changes: Pull panel name from the panel/test data instead of the sample run data.
 -- The surveillance data from SPF_workflow assay does not include an objectid, which
 -- is needed to join back with the run data. 10/20/2021 tjh

SELECT
    b.id,
    b.date,
    b.serviceTestId.serviceId.ServiceName AS PanelName,
    b.serviceTestId.testName AS TestName,
    coalesce(b.runId, b.objectid) as runId,
    b.resultoorindicator,
    CASE
    WHEN b.result IS NULL THEN  b.qualresult
      ELSE CAST(CAST(b.result AS float) AS VARCHAR)
    END as result
  FROM study.labworkResults b
  WHERE b.serviceTestId.includeInPanel = true and b.qcstate.publicdata = true and b.serviceTestid.ServiceId.Dataset = 'Surveillance'

union

SELECT
  b.id,
  b.date,
  b.serviceTestId.serviceId.ServiceName AS PanelName,
  b.serviceTestId.testName AS TestName,
  coalesce(b.runId, b.objectid) as runId,
  b.resultoorindicator,
  CASE
  WHEN b.result IS NULL THEN b.qualresult
    ELSE CAST(CAST(b.result AS float) AS VARCHAR)
  END as result
  FROM study.assay_labworkResults b
  WHERE b.serviceTestId.includeInPanel = true and b.qcstate.publicdata = true and b.serviceTestid.ServiceId.Dataset = 'Surveillance'

union

SELECT
    b.id,
    b.date,
    b.serviceTestId.serviceId.ServiceName AS PanelName,
    b.serviceTestId.testName AS TestName,
    coalesce(b.runId, cast(b.Sequencenum as varchar)) as runId,
    b.resultoorindicator,
    CASE
        WHEN b.result IS NULL THEN b.qualresult
        ELSE CAST(CAST(b.result AS float) AS VARCHAR)
        END as result
FROM study.labworkTaqman b
WHERE b.serviceTestId.includeInPanel = true and b.qcstate.publicdata = true and b.serviceTestid.ServiceId.Dataset = 'Surveillance'
