/*
 * Copyright (c) 2019 LabKey Corporation
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
    m.Id AS Id,
    'A001: ' + m.A001Status + ' B003: ' + m.B003Status + ' B008: '  +  m.B008Status + ' B017: ' +  m.B017Status as mhcSummary,
    lsid,
    qcstate.publicData as publicData


FROM study.mhcStatus m