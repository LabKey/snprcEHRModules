/*
 * Copyright (c) 2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
-- Dropping UNIQUE idx_labwork_services_serviceid [ServiceId] because it overlaps with PRIMARY pk_snprc_labwork_services [ServiceId]
DROP INDEX snprc_ehr.idx_labwork_services_serviceid;
