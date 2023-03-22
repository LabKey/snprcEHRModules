import { SchemaQuery } from '@labkey/components';

const SND_SCHEMA = 'snd';
export const SND_TABLES = {
    LOOKUPS: SchemaQuery.create(SND_SCHEMA, 'lookups'),
    LOOKUP_SETS: SchemaQuery.create(SND_SCHEMA, 'lookupSets'),
    SCHEMA: SND_SCHEMA
}

export const SCHEMAS = {
    SND_TABLES
};