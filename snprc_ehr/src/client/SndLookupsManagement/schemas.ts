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