/*
 * Copyright (c) 2018 LabKey Corporation
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
  b.packageId,
  b.name as pkg_name,
  b.pkgType,
  group_concat(b.description) as categories

FROM (
       select pcj.packageId,
         p.name,
         pc.description,
         p.pkgType
       from  snprc_ehr.package_category_junction pcj
       inner join snprc_ehr.package_category pc on pcj.categoryId = pc.id
       INNER JOIN snprc_ehr.package p on p.id = pcj.packageId
     ) b

GROUP BY b.packageId, b.name, b.pkgType