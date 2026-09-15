import { Filter, Query } from '@labkey/api';
import { COMPLETED, SCORED_FIELDS } from '../constants/fields';

const SCHEMA = 'study';
const QUERY = 'BiocontainmentObservations';

const COLUMNS = [
    'lsid', 'Id', 'date', 'Location', 'Comment', 'QCState/Label',
    'createdBy', 'createdBy/DisplayName', 'created', 'modifiedBy/DisplayName', 'modified',
].concat(...SCORED_FIELDS.map(f => [f.name, `${f.name}Comments`].concat(f.carryOver ? [f.carryOver] : [])));

export type ObservationRow = Record<string, any>;

export const fetchObservation = (lsid: string): Promise<ObservationRow> =>
    new Promise((resolve, reject) => {
        Query.selectRows({
            schemaName: SCHEMA,
            queryName: QUERY,
            columns: COLUMNS,
            filterArray: [Filter.create('lsid', lsid)],
            success: data => resolve(data.rows[0]),
            failure: reject,
        });
    });

export const approveObservations = (lsids: string[]): Promise<any> =>
    new Promise((resolve, reject) => {
        Query.updateRows({
            schemaName: SCHEMA,
            queryName: QUERY,
            rows: lsids.map(lsid => ({ lsid, QCStateLabel: COMPLETED })),
            success: resolve,
            failure: reject,
        });
    });

export interface Correction {
    field: string;
    value: any;
    reason: string;
}

export const correctObservation = (lsid: string, corrections: Correction[]): Promise<any> => {
    const row: ObservationRow = { lsid };
    corrections.forEach(c => {
        row[c.field] = c.value;
        row[`${c.field}Comments`] = c.reason;
    });
    return new Promise((resolve, reject) => {
        Query.updateRows({
            schemaName: SCHEMA,
            queryName: QUERY,
            rows: [row],
            success: resolve,
            failure: reject,
        });
    });
};