/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
    d.Id AS Id,
    h.date as FirstHousingDate,
    h.room as FirstHousingRoom,
    h.room.area.description as FirstHousingRoomDescription
FROM study.demographics d


--date of first housing
LEFT JOIN study.housing as h on h.id = d.id and h.qcstate.publicdata = true
    and h.date = (select min(c1.date) from study.housing as c1
                   where h.id = c1.id)
