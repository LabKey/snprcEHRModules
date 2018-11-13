/*
 * Copyright (c) 2017 LabKey Corporation
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
create VIEW labkey_export.v_export_flags as
SELECT [id]
      ,[attribute]
      ,[comment]
      ,[tid]
      ,[object_id]
      ,[user_name]
      ,[entry_date_tm]
      ,[timestamp]
  FROM [animal].[dbo].[attributes]

  go

  GRANT SELECT, INSERT, UPDATE, DELETE ON labkey_export.v_export_flags TO z_labkey
  GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.attributes TO z_labkey
  go