/*
 * Copyright (c) 2015-2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT

  agm.id,
  agm.date,
  agm.enddate,
  agm.groupId.name

FROM study.animal_group_members as agm
where agm.groupId.category_code.description like '%colonies%'