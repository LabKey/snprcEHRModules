/*
 * Copyright (c) 2023-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
import { SchemaQuery } from '@labkey/components';

const SND_SCHEMA = 'snd';
export const SND_TABLES = {
    LOOKUPS: new SchemaQuery(SND_SCHEMA, 'lookups'),
    LOOKUP_SETS: new SchemaQuery(SND_SCHEMA, 'lookupSets'),
    SCHEMA: SND_SCHEMA
};

export const SCHEMAS = {
    SND_TABLES
};