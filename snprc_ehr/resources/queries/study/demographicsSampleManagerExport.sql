/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT demographics.Id,
demographics.gender as sex,
demographics.species,
demographics.species.arc_species_code as arc_species_code,
demographics.birth,
demographics.death,
demographics.lastDayAtCenter,
demographics.calculated_status as status,
demographics.dam,
demographics.sire,
id.age.ageFriendly as age,
demographics.history,
demographics.Created,
demographics.CreatedBy,
demographics.Modified,
demographics.ModifiedBy
FROM demographics