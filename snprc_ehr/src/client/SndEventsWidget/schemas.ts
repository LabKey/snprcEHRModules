/*
 * Copyright (c) 2023-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
import { SchemaQuery } from '@labkey/components';

const SND_SCHEMA = 'snd';
export const SND_QUERIES = {
    PROCEDURES: new SchemaQuery(SND_SCHEMA, 'ProcedureEventListing'),
    SCHEMA: SND_SCHEMA
};

export const SCHEMAS = {
    SND_QUERIES
};