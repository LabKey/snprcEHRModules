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
-- working code to emulate acq_disp
-- 8/31/2016 Scott Rouse

SELECT
a.id as id, a.date as acq_date,
          a.acquisitionType.description + ' (' + cast(a.AcquisitionType as varchar(10)) + ')' as acquisitionType,
            d.date as disp_date,
            d.dispositionType.description + ' (' + cast(d.dispositionType as varchar(10))  + ')' as dispositionType,

FROM arrival a
	LEFT OUTER JOIN departure d
	on d.id = a.id and a.date < ifnull(d.date,curdate())

where a.date < ifnull(d.date,curdate())
  and   ( d.date = (select min(z.date) from departure z where z.id = d.id and z.date > a.date)
                 or
       d.date is NULL)