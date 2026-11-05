import { Filter, Query } from '@labkey/api';
import {
    approveObservations,
    correctObservation,
    fetchObservation,
    fetchPriorObservation,
    historyUrl,
} from '../api/observation';

jest.mock('@labkey/api', () => {
    const actual = jest.requireActual('@labkey/api');
    return {
        ...actual,
        ActionURL: {
            buildURL: jest.fn((controller, action, container, params) => ({ action, controller, params })),
        },
        Query: { selectRows: jest.fn(), updateRows: jest.fn() },
    };
});

const selectRows = Query.selectRows as jest.Mock;
const updateRows = Query.updateRows as jest.Mock;

// Answer the next LabKey call the way the server would
const succeedWith = (mock: jest.Mock, data: unknown) => mock.mockImplementation(config => config.success(data));
const failWith = (mock: jest.Mock, error: unknown) => mock.mockImplementation(config => config.failure(error));

const filterSummary = (filters: Filter.IFilter[]) =>
    filters.map(f => [f.getColumnName(), f.getFilterType().getURLSuffix(), f.getValue()]);

beforeEach(() => {
    jest.clearAllMocks();
});

describe('approveObservations', () => {
    test('sends only the lsid and the Completed QC state; the trigger stamps the reviewer', async () => {
        succeedWith(updateRows, { rows: [] });

        await approveObservations(['lsid-1']);

        const config = updateRows.mock.calls[0][0];
        expect(config.schemaName).toBe('study');
        expect(config.queryName).toBe('BiocontainmentObservations');
        expect(config.rows).toEqual([{ lsid: 'lsid-1', QCStateLabel: 'Completed' }]);
    });

    test('rejects with the server error, e.g. the author trying to approve', async () => {
        const error = { exception: 'This observation must be reviewed by someone other than its author' };
        failWith(updateRows, error);

        await expect(approveObservations(['lsid-1'])).rejects.toBe(error);
    });
});

describe('correctObservation', () => {
    test('sends each changed value with its reason in the matching Comments column', async () => {
        succeedWith(updateRows, { rows: [] });

        await correctObservation('lsid-1', [
            { field: 'Responsiveness', reason: 'Entered on the wrong row', value: '8' },
            { field: 'Stool', reason: 'Was 2R', value: '2D' },
        ]);

        expect(updateRows.mock.calls[0][0].rows).toEqual([
            {
                lsid: 'lsid-1',
                Responsiveness: '8',
                ResponsivenessComments: 'Entered on the wrong row',
                Stool: '2D',
                StoolComments: 'Was 2R',
            },
        ]);
    });

    test('sends the carry-over with its parameter, sharing the reason', async () => {
        succeedWith(updateRows, { rows: [] });

        await correctObservation('lsid-1', [{ carryOver: 1, field: 'Petechia', reason: 'Carried from AM', value: 2 }]);

        expect(updateRows.mock.calls[0][0].rows[0]).toEqual({
            lsid: 'lsid-1',
            Petechia: 2,
            PetechiaCO: 1,
            PetechiaComments: 'Carried from AM',
        });
    });

    test('ignores a carry-over on a field that does not have one', async () => {
        succeedWith(updateRows, { rows: [] });

        await correctObservation('lsid-1', [{ carryOver: 1, field: 'Bleeding', reason: 'Typo', value: 1 }]);

        expect(updateRows.mock.calls[0][0].rows[0]).toEqual({ lsid: 'lsid-1', Bleeding: 1, BleedingComments: 'Typo' });
    });

    test('sends the comment only when one is passed, and an empty comment as null', async () => {
        succeedWith(updateRows, { rows: [] });

        await correctObservation('lsid-1', [{ field: 'Bleeding', reason: 'Typo', value: 1 }]);
        expect(updateRows.mock.calls[0][0].rows[0]).not.toHaveProperty('Comment');

        await correctObservation('lsid-1', [], 'Lethargic after feeding');
        expect(updateRows.mock.calls[1][0].rows[0]).toEqual({ Comment: 'Lethargic after feeding', lsid: 'lsid-1' });

        await correctObservation('lsid-1', [], '');
        expect(updateRows.mock.calls[2][0].rows[0]).toEqual({ Comment: null, lsid: 'lsid-1' });
    });

    test('rejects with the server error, e.g. a missing reason', async () => {
        const error = { exception: 'A reason is required for each changed value' };
        failWith(updateRows, error);

        await expect(correctObservation('lsid-1', [{ field: 'Bleeding', reason: '', value: 1 }])).rejects.toBe(error);
    });
});

describe('fetchObservation', () => {
    test('selects the one row by lsid, with every scored, reason and carry-over column', async () => {
        const row = { lsid: 'lsid-1', Id: '12345' };
        succeedWith(selectRows, { rows: [row] });

        await expect(fetchObservation('lsid-1')).resolves.toBe(row);

        const config = selectRows.mock.calls[0][0];
        expect(filterSummary(config.filterArray)).toEqual([['lsid', 'eq', 'lsid-1']]);
        expect(config.columns).toEqual(
            expect.arrayContaining(['lsid', 'QCState/Label', 'Petechia', 'PetechiaComments', 'PetechiaCO', 'Stool'])
        );
        expect(config.columns).not.toContain('StoolCO');
    });
});

describe('fetchPriorObservation', () => {
    const row = { date: '2026/09/28 13:45:00', Id: '12345', Location: 23.03 };

    test('asks for the latest earlier observation of the same animal at the same location', async () => {
        succeedWith(selectRows, { rows: [{ lsid: 'prior' }] });

        await expect(fetchPriorObservation(row)).resolves.toEqual({ lsid: 'prior' });

        const config = selectRows.mock.calls[0][0];
        // LESS_THAN, not DATE_LESS_THAN: an animal can have two observations on the same day
        expect(filterSummary(config.filterArray)).toEqual([
            ['Id', 'eq', '12345'],
            ['Location', 'eq', 23.03],
            ['date', 'lt', '2026/09/28 13:45:00'],
        ]);
        expect(config.sort).toBe('-date');
        expect(config.maxRows).toBe(1);
    });

    test('resolves undefined for the first observation', async () => {
        succeedWith(selectRows, { rows: [] });

        await expect(fetchPriorObservation(row)).resolves.toBeUndefined();
    });
});

describe('historyUrl', () => {
    test('opens the dataset filtered to the animal and location, newest first', () => {
        expect(historyUrl({ Id: '12345', Location: 23.03 })).toEqual({
            action: 'executeQuery',
            controller: 'query',
            params: {
                'query.Id~eq': '12345',
                'query.Location~eq': 23.03,
                'query.queryName': 'BiocontainmentObservations',
                'query.sort': '-date',
                schemaName: 'study',
            },
        });
    });
});
