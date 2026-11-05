import { ActionURL, Filter, Query } from '@labkey/api';
import { carryOverOf, COMPLETED, HUSBANDRY_FIELDS, notSedatedOf, SCORED_FIELDS } from '../constants/fields';

const SCHEMA = 'study';
const QUERY = 'BiocontainmentObservations';

const COLUMNS = [
    'lsid',
    'Id',
    'date',
    'Location',
    'FormCode',
    'FormType',
    'FoundDead',
    'FoundDeadComments',
    'DehydrationNS',
    'Comment',
    'QCState/Label',
    'createdBy',
    'createdBy/DisplayName',
    'created',
    'modifiedBy/DisplayName',
    'modified',
]
    .concat(...SCORED_FIELDS.map(f => [f.name, `${f.name}Comments`].concat(f.carryOver ? [f.carryOver] : [])))
    .concat(...HUSBANDRY_FIELDS.map(f => [f.name, `${f.name}Comments`]));

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
    carryOver?: number;
    field: string;
    notSedated?: number;
    reason: string;
    value: any;
}

// comment is only sent when it changed; an empty comment clears it, and an empty value is sent as null
export const correctObservation = (lsid: string, corrections: Correction[], comment?: string): Promise<any> => {
    const row: ObservationRow = { lsid };
    if (comment !== undefined) row.Comment = comment === '' ? null : comment;
    corrections.forEach(c => {
        row[c.field] = c.value === '' || c.value === undefined ? null : c.value;
        row[`${c.field}Comments`] = c.reason;
        const co = carryOverOf(c.field);
        if (co && c.carryOver !== undefined) row[co] = c.carryOver;
        const ns = notSedatedOf(c.field);
        if (ns && c.notSedated !== undefined) row[ns] = c.notSedated;
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

// Same animal, same location, same form (scores are never compared across forms, 9/22).
// Any QC state: the tech saw the prior whether or not it had been approved.
const historyFilters = (row: ObservationRow) => [
    Filter.create('Id', row.Id),
    Filter.create('Location', row.Location),
    Filter.create('FormType', row.FormType),
];

// Most recent observation before this one
export const fetchPriorObservation = (row: ObservationRow): Promise<ObservationRow | undefined> =>
    new Promise((resolve, reject) => {
        Query.selectRows({
            schemaName: SCHEMA,
            queryName: QUERY,
            columns: COLUMNS,
            // LESS_THAN, not DATE_LESS_THAN: the date filter drops the time, and an animal can have two observations in a day
            filterArray: historyFilters(row).concat(Filter.create('date', row.date, Filter.Types.LESS_THAN)),
            sort: '-date',
            maxRows: 1,
            success: data => resolve(data.rows[0]),
            failure: reject,
        });
    });

// Full history for the animal at this location on this form, newest first
export const historyUrl = (row: ObservationRow): string =>
    ActionURL.buildURL('query', 'executeQuery', undefined, {
        schemaName: SCHEMA,
        'query.queryName': QUERY,
        'query.Id~eq': row.Id,
        'query.Location~eq': row.Location,
        'query.FormType~eq': row.FormType,
        'query.sort': '-date',
    });
