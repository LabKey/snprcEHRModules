import { SchemaQuery } from '@labkey/components';

const SND_SCHEMA = 'snd';
export const SND_QUERIES = {
    PROCEDURES: new SchemaQuery(SND_SCHEMA, 'ProcedureEventListing'),
    SCHEMA: SND_SCHEMA
};

export const SCHEMAS = {
    SND_QUERIES
};