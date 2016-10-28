/*
 * Copyright (c) 2015-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT

agm.id,
agm.date,
agm.enddate,
agm.groupId.name,
ag.comment

FROM study.animal_group_members as agm
JOIN ehr.animal_groups ag on (ag.category = 'Breeding' and agm.groupId = ag.rowid)
