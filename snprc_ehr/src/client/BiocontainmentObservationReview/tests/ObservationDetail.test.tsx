import React from 'react';
import { render, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import ObservationDetail from '../components/ObservationDetail';
import { correctObservation, fetchPriorObservation, ObservationRow } from '../api/observation';
import { FOUR_POINT_FIELDS, SCORED_FIELDS } from '../constants/fields';

jest.mock('../api/observation', () => ({
    correctObservation: jest.fn(),
    fetchPriorObservation: jest.fn(),
    historyUrl: jest.fn(() => '#history'),
}));

const mockCorrect = correctObservation as jest.Mock;
const mockFetchPrior = fetchPriorObservation as jest.Mock;

// A complete 15-point observation with every scored field at 0 and every carry-over at No
const makeRow = (overrides: Record<string, any> = {}): ObservationRow => {
    const row: ObservationRow = {
        lsid: 'lsid-1',
        Id: '12345',
        Location: 23.03,
        date: '2026/09/28 13:45:00',
        FormCode: 'TXB904-1-R01',
        FormType: '15PT',
        FoundDead: 0,
        CageCleaning: 1,
        Water: null,
        Comment: 'Quiet morning',
        'createdBy/DisplayName': 'observer',
    };
    SCORED_FIELDS.forEach(f => {
        row[f.name] = f.name === 'Stool' ? '0' : 0;
        if (f.carryOver) row[f.carryOver] = 0;
    });
    return { ...row, ...overrides };
};

// A complete 4-point observation: every parameter at 0, sedated, not found dead
const makeFourPointRow = (overrides: Record<string, any> = {}): ObservationRow => {
    const row: ObservationRow = {
        lsid: 'lsid-4',
        Id: '23456',
        Location: 41.01,
        date: '2026/10/30 08:15:00',
        FormCode: 'TXB904-1-ABSL4-R00',
        FormType: '4PT',
        FoundDead: 0,
        DehydrationNS: 0,
        CageCleaning: 2,
        Water: 1,
        Comment: null,
        'createdBy/DisplayName': 'observer',
    };
    FOUR_POINT_FIELDS.forEach(f => {
        row[f.name] = f.name === 'Stool' ? '0' : 0;
    });
    return { ...row, ...overrides };
};

// The table row for one parameter, so its value, carry-over and reason controls can be found by label
const parameterRow = (label: string) => within(screen.getByText(label).closest('tr'));

const renderDetail = async (row: ObservationRow = makeRow(), onSaved = jest.fn(), onEditingChange = jest.fn()) => {
    render(<ObservationDetail onEditingChange={onEditingChange} onSaved={onSaved} row={row} />);
    // Let the prior-observation fetch settle before asserting
    await waitFor(() => expect(mockFetchPrior).toHaveBeenCalled());
    return onSaved;
};

const saveButton = () => screen.getByRole('button', { name: 'Save correction' });

beforeEach(() => {
    jest.clearAllMocks();
    mockFetchPrior.mockResolvedValue(undefined);
    mockCorrect.mockResolvedValue({});
});

describe('ObservationDetail, read only', () => {
    test('shows the animal, location, time, author and comment', async () => {
        await renderDetail();

        expect(screen.getByText('12345 · Location 23.03 · 09/28/2026 13:45')).toBeInTheDocument();
        expect(screen.getByText('Recorded by observer')).toBeInTheDocument();
        expect(screen.getByText('Comment: Quiet morning')).toBeInTheDocument();
    });

    test('lists all 13 parameters with the calculated clinical score', async () => {
        await renderDetail(makeRow({ Respiration: 8, Stool: '2R' }));

        SCORED_FIELDS.forEach(f => expect(screen.getByText(f.label)).toBeInTheDocument());
        expect(screen.getByText('Clinical Score:')).toHaveTextContent('Clinical Score: 10');
    });

    test('shows carry-overs as Yes or No', async () => {
        await renderDetail(makeRow({ PetechiaCO: 1 }));

        expect(parameterRow('Petechia').getByText('Yes')).toBeInTheDocument();
        expect(parameterRow('Weight Loss').getByText('No')).toBeInTheDocument();
    });

    test('hides the Prior column when there is no earlier observation', async () => {
        await renderDetail();

        expect(screen.queryByRole('link', { name: 'Prior' })).not.toBeInTheDocument();
    });

    test('shows the prior values and prior score, linked to the full history', async () => {
        mockFetchPrior.mockResolvedValue(makeRow({ lsid: 'prior', Bleeding: 2 }));
        await renderDetail();

        const link = await screen.findByRole('link', { name: 'Prior' });
        expect(link).toHaveAttribute('href', '#history');
        expect(parameterRow('Bleeding').getByText('2')).toBeInTheDocument();
        expect(screen.getByText('(prior 2)', { exact: false })).toBeInTheDocument();
    });

    test('shows an error if the prior observation cannot be loaded', async () => {
        mockFetchPrior.mockRejectedValue({ exception: 'Query failed' });
        await renderDetail();

        expect(await screen.findByText('Query failed')).toBeInTheDocument();
    });
});

describe('ObservationDetail, corrections', () => {
    test('Save stays disabled until a value actually changes', async () => {
        await renderDetail();
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        expect(saveButton()).toBeDisabled();
    });

    test('a changed value needs a reason before it can be saved', async () => {
        await renderDetail();
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        const bleeding = parameterRow('Bleeding');
        userEvent.selectOptions(bleeding.getByRole('combobox'), '2');
        expect(saveButton()).toBeDisabled();
        expect(screen.getByText('Bleeding').closest('tr').querySelector('.needs-reason')).not.toBeNull();

        userEvent.type(bleeding.getByRole('textbox'), 'Entered on the wrong animal');
        expect(saveButton()).toBeEnabled();
    });

    test('a reason of only spaces does not count', async () => {
        await renderDetail();
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        const bleeding = parameterRow('Bleeding');
        userEvent.selectOptions(bleeding.getByRole('combobox'), '1');
        userEvent.type(bleeding.getByRole('textbox'), '   ');

        expect(saveButton()).toBeDisabled();
    });

    test('changing a value back to the original is not a change', async () => {
        await renderDetail();
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        const select = parameterRow('Bleeding').getByRole('combobox');
        userEvent.selectOptions(select, '2');
        userEvent.selectOptions(select, '0');

        expect(saveButton()).toBeDisabled();
    });

    test('changing only a carry-over also needs the parameter reason', async () => {
        await renderDetail();
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        const petechia = parameterRow('Petechia');
        const [, carryOver] = petechia.getAllByRole('combobox');
        userEvent.selectOptions(carryOver, '1');
        expect(saveButton()).toBeDisabled();

        userEvent.type(petechia.getByRole('textbox'), 'Carried from AM');
        expect(saveButton()).toBeEnabled();
    });

    test('the clinical score follows unsaved edits', async () => {
        await renderDetail();
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        userEvent.selectOptions(parameterRow('Responsiveness').getByRole('combobox'), '15');

        expect(screen.getByText('Clinical Score:')).toHaveTextContent('Clinical Score: 15');
    });

    test('saves only the changed parameters, with their reasons, then reports back', async () => {
        const onSaved = await renderDetail();
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        const bleeding = parameterRow('Bleeding');
        userEvent.selectOptions(bleeding.getByRole('combobox'), '2');
        userEvent.type(bleeding.getByRole('textbox'), 'Entered on the wrong animal');

        const petechia = parameterRow('Petechia');
        userEvent.selectOptions(petechia.getAllByRole('combobox')[1], '1');
        userEvent.type(petechia.getByRole('textbox'), 'Carried from AM');

        // Touched but unchanged: must not be sent
        userEvent.type(parameterRow('Stool').getByRole('textbox'), 'no change');

        userEvent.click(saveButton());

        await waitFor(() => expect(onSaved).toHaveBeenCalledTimes(1));
        expect(mockCorrect).toHaveBeenCalledWith(
            'lsid-1',
            [
                { carryOver: undefined, field: 'Bleeding', reason: 'Entered on the wrong animal', value: '2' },
                { carryOver: 1, field: 'Petechia', reason: 'Carried from AM', value: 0 },
            ],
            // Comment untouched, so it is not sent
            undefined
        );
        expect(screen.getByRole('button', { name: 'Edit Values' })).toBeInTheDocument();
    });

    test('shows the server error and stays in edit mode when the save is rejected', async () => {
        mockCorrect.mockRejectedValue({ exception: 'A reason is required for each changed value' });
        const onSaved = await renderDetail();
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        const bleeding = parameterRow('Bleeding');
        userEvent.selectOptions(bleeding.getByRole('combobox'), '1');
        userEvent.type(bleeding.getByRole('textbox'), 'Typo');
        userEvent.click(saveButton());

        expect(await screen.findByText('A reason is required for each changed value')).toBeInTheDocument();
        expect(onSaved).not.toHaveBeenCalled();
        expect(saveButton()).toBeInTheDocument();
    });

    test('Cancel discards the edits', async () => {
        await renderDetail();
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));
        userEvent.selectOptions(parameterRow('Bleeding').getByRole('combobox'), '2');

        userEvent.click(screen.getByRole('button', { name: 'Cancel' }));
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        expect(parameterRow('Bleeding').getByRole('combobox')).toHaveValue('0');
        expect(screen.getByText('Clinical Score:')).toHaveTextContent('Clinical Score: 0');
        expect(mockCorrect).not.toHaveBeenCalled();
    });

    test('the reason must differ from the one already stored', async () => {
        await renderDetail(makeRow({ BleedingComments: 'Entered on the wrong animal' }));
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        const bleeding = parameterRow('Bleeding');
        userEvent.selectOptions(bleeding.getByRole('combobox'), '2');
        userEvent.type(bleeding.getByRole('textbox'), 'Entered on the wrong animal');
        expect(saveButton()).toBeDisabled();

        userEvent.type(bleeding.getByRole('textbox'), ' again');
        expect(saveButton()).toBeEnabled();
    });

    test('Cancel clears the error from a rejected save', async () => {
        mockCorrect.mockRejectedValue({ exception: 'Save rejected' });
        await renderDetail();
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        const bleeding = parameterRow('Bleeding');
        userEvent.selectOptions(bleeding.getByRole('combobox'), '1');
        userEvent.type(bleeding.getByRole('textbox'), 'Typo');
        userEvent.click(saveButton());
        await screen.findByText('Save rejected');

        userEvent.click(screen.getByRole('button', { name: 'Cancel' }));

        expect(screen.queryByText('Save rejected')).not.toBeInTheDocument();
    });

    test('shows a JavaScript or network error message when there is no LabKey exception', async () => {
        mockCorrect.mockRejectedValue(new Error('Failed to fetch'));
        await renderDetail();
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        const bleeding = parameterRow('Bleeding');
        userEvent.selectOptions(bleeding.getByRole('combobox'), '1');
        userEvent.type(bleeding.getByRole('textbox'), 'Typo');
        userEvent.click(saveButton());

        expect(await screen.findByText('Failed to fetch')).toBeInTheDocument();
    });

    test('tells the page when editing starts and stops, so it can disable Approve', async () => {
        const onEditingChange = jest.fn();
        await renderDetail(makeRow(), jest.fn(), onEditingChange);
        expect(onEditingChange).toHaveBeenLastCalledWith(false);

        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));
        expect(onEditingChange).toHaveBeenLastCalledWith(true);

        userEvent.click(screen.getByRole('button', { name: 'Cancel' }));
        expect(onEditingChange).toHaveBeenLastCalledWith(false);
    });
});

describe('ObservationDetail, missing values', () => {
    test('marks a missing value instead of leaving it blank', async () => {
        await renderDetail(makeRow({ Bleeding: null }));

        expect(parameterRow('Bleeding').getByText('Missing')).toBeInTheDocument();
    });

    test('a missing value shows as unselected, not as the first choice, and can be filled in with a reason', async () => {
        const onSaved = await renderDetail(makeRow({ Bleeding: null }));
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        const bleeding = parameterRow('Bleeding');
        const select = bleeding.getByRole('combobox') as HTMLSelectElement;
        expect(select.value).toBe('');
        expect(bleeding.getByRole('option', { name: 'Select a value' })).toBeDisabled();
        expect(saveButton()).toBeDisabled();

        userEvent.selectOptions(select, '1');
        userEvent.type(bleeding.getByRole('textbox'), 'Missing from the tablet');
        userEvent.click(saveButton());

        await waitFor(() => expect(onSaved).toHaveBeenCalled());
        expect(mockCorrect).toHaveBeenCalledWith(
            'lsid-1',
            [{ carryOver: undefined, field: 'Bleeding', reason: 'Missing from the tablet', value: '1' }],
            undefined
        );
    });

    test('Save stays disabled while another value is still missing', async () => {
        await renderDetail(makeRow({ Bleeding: null }));
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        const stool = parameterRow('Stool');
        userEvent.selectOptions(stool.getByRole('combobox'), '1');
        userEvent.type(stool.getByRole('textbox'), 'Entered on the wrong animal');
        expect(saveButton()).toBeDisabled();
        expect(screen.getByText(/Fill in every missing value before saving: Bleeding/)).toBeInTheDocument();

        const bleeding = parameterRow('Bleeding');
        userEvent.selectOptions(bleeding.getByRole('combobox'), '0');
        userEvent.type(bleeding.getByRole('textbox'), 'Missing from the tablet');
        expect(saveButton()).toBeEnabled();
        expect(screen.queryByText(/Fill in every missing value/)).not.toBeInTheDocument();
    });

    test('a complete record has no blank choice', async () => {
        await renderDetail();
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        expect(parameterRow('Bleeding').queryByRole('option', { name: 'Select a value' })).not.toBeInTheDocument();
    });
});

describe('ObservationDetail, comment', () => {
    const commentBox = () => screen.getByLabelText('Comment');

    test('is read only until editing starts', async () => {
        await renderDetail();

        expect(screen.getByText('Comment: Quiet morning')).toBeInTheDocument();
        expect(screen.queryByLabelText('Comment')).not.toBeInTheDocument();
    });

    test('is editable, limited to the 80 characters CAMP stores', async () => {
        await renderDetail();
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        expect(commentBox()).toHaveValue('Quiet morning');
        expect(commentBox()).toHaveAttribute('maxLength', '80');
    });

    test('a comment change can be saved on its own, with no reason', async () => {
        const onSaved = await renderDetail();
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        userEvent.clear(commentBox());
        userEvent.type(commentBox(), 'Lethargic after feeding');
        expect(saveButton()).toBeEnabled();

        userEvent.click(saveButton());

        await waitFor(() => expect(onSaved).toHaveBeenCalledTimes(1));
        expect(mockCorrect).toHaveBeenCalledWith('lsid-1', [], 'Lethargic after feeding');
    });

    test('clearing the comment sends an empty comment', async () => {
        const onSaved = await renderDetail();
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        userEvent.clear(commentBox());
        userEvent.click(saveButton());

        await waitFor(() => expect(onSaved).toHaveBeenCalledTimes(1));
        expect(mockCorrect).toHaveBeenCalledWith('lsid-1', [], '');
    });

    test('retyping the same comment, or only adding spaces, is not a change', async () => {
        await renderDetail();
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        userEvent.clear(commentBox());
        userEvent.type(commentBox(), 'Quiet morning  ');

        expect(saveButton()).toBeDisabled();
    });

    test('a comment change is saved together with value corrections', async () => {
        const onSaved = await renderDetail();
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        const bleeding = parameterRow('Bleeding');
        userEvent.selectOptions(bleeding.getByRole('combobox'), '1');
        userEvent.type(bleeding.getByRole('textbox'), 'Typo');
        userEvent.type(commentBox(), ', small bleed noted');
        userEvent.click(saveButton());

        await waitFor(() => expect(onSaved).toHaveBeenCalledTimes(1));
        expect(mockCorrect).toHaveBeenCalledWith(
            'lsid-1',
            [{ carryOver: undefined, field: 'Bleeding', reason: 'Typo', value: '1' }],
            'Quiet morning, small bleed noted'
        );
    });

    test('Cancel discards a comment edit', async () => {
        await renderDetail();
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));
        userEvent.clear(commentBox());
        userEvent.type(commentBox(), 'Something else');

        userEvent.click(screen.getByRole('button', { name: 'Cancel' }));
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        expect(commentBox()).toHaveValue('Quiet morning');
    });
});

describe('ObservationDetail, 4-point form', () => {
    const editValues = () => userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));
    const foundDeadSelect = () => parameterRow('Found Dead').getByRole('combobox');

    test('lists only the 4-point parameters, with an NS column and the Responsiveness score', async () => {
        await renderDetail(makeFourPointRow({ Responsiveness: 3, Bleeding: 2 }));

        FOUR_POINT_FIELDS.forEach(f => expect(screen.getByText(f.label)).toBeInTheDocument());
        expect(screen.queryByText('Weight Loss')).not.toBeInTheDocument();
        expect(screen.getByRole('columnheader', { name: 'Not sedated' })).toBeInTheDocument();
        expect(screen.queryByRole('columnheader', { name: 'Carry over' })).not.toBeInTheDocument();
        expect(screen.getByText('Responsiveness Score:')).toHaveTextContent('Responsiveness Score: 3');
        expect(screen.getByText('4-point (ABSL-4) form (TXB904-1-ABSL4-R00)')).toBeInTheDocument();
    });

    test('a found-dead record shows N/A for every parameter and FD as the score', async () => {
        const nulls = Object.fromEntries(FOUR_POINT_FIELDS.map(f => [f.name, null]));
        await renderDetail(makeFourPointRow({ ...nulls, FoundDead: 1, DehydrationNS: null }));

        expect(parameterRow('Found Dead').getByText('Yes')).toBeInTheDocument();
        FOUR_POINT_FIELDS.forEach(f => expect(parameterRow(f.label).getByText('N/A')).toBeInTheDocument());
        expect(screen.getByText('Responsiveness Score:')).toHaveTextContent('Responsiveness Score: FD');
    });

    test('a not-sedated record shows NS for Dehydration', async () => {
        await renderDetail(makeFourPointRow({ Dehydration: null, DehydrationNS: 1 }));

        expect(parameterRow('Dehydration').getByText('NS')).toBeInTheDocument();
        expect(parameterRow('Dehydration').getByText('Yes')).toBeInTheDocument();
    });

    test('marking found dead clears every parameter, which share the Found Dead reason', async () => {
        const onSaved = await renderDetail(makeFourPointRow());
        editValues();

        userEvent.selectOptions(foundDeadSelect(), '1');
        expect(parameterRow('Responsiveness').getByText('N/A')).toBeInTheDocument();
        expect(saveButton()).toBeDisabled();

        userEvent.type(parameterRow('Found Dead').getByRole('textbox'), 'Found dead at AM check');
        expect(saveButton()).toBeEnabled();
        userEvent.click(saveButton());

        await waitFor(() => expect(onSaved).toHaveBeenCalledTimes(1));
        const [lsid, corrections] = mockCorrect.mock.calls[0];
        expect(lsid).toBe('lsid-4');
        expect(corrections.find(c => c.field === 'FoundDead')).toMatchObject({
            reason: 'Found dead at AM check',
            value: '1',
        });
        FOUR_POINT_FIELDS.forEach(f =>
            expect(corrections.find(c => c.field === f.name)).toMatchObject({
                reason: 'Found dead at AM check',
                value: null,
            })
        );
        expect(corrections.find(c => c.field === 'Dehydration').notSedated).toBeNull();
    });

    test('un-marking found dead before saving restores the recorded values', async () => {
        await renderDetail(makeFourPointRow({ Bleeding: 2 }));
        editValues();

        userEvent.selectOptions(foundDeadSelect(), '1');
        userEvent.selectOptions(foundDeadSelect(), '0');

        expect(parameterRow('Bleeding').getByRole('combobox')).toHaveValue('2');
        expect(saveButton()).toBeDisabled();
    });

    test('un-marking a saved found-dead record needs every value before it can be saved', async () => {
        const nulls = Object.fromEntries(FOUR_POINT_FIELDS.map(f => [f.name, null]));
        const onSaved = await renderDetail(makeFourPointRow({ ...nulls, FoundDead: 1, DehydrationNS: null }));
        editValues();

        userEvent.selectOptions(foundDeadSelect(), '0');
        userEvent.type(parameterRow('Found Dead').getByRole('textbox'), 'Wrong animal');
        expect(parameterRow('Responsiveness').getByRole('combobox')).toHaveValue('');
        expect(saveButton()).toBeDisabled();

        FOUR_POINT_FIELDS.forEach(f => userEvent.selectOptions(parameterRow(f.label).getAllByRole('combobox')[0], '1'));
        expect(saveButton()).toBeEnabled();
        userEvent.click(saveButton());

        await waitFor(() => expect(onSaved).toHaveBeenCalledTimes(1));
        const corrections = mockCorrect.mock.calls[0][1];
        expect(corrections.find(c => c.field === 'Dehydration')).toMatchObject({
            notSedated: 0,
            reason: 'Wrong animal',
            value: '1',
        });
    });

    test('marking NS clears Dehydration and saves with its reason', async () => {
        const onSaved = await renderDetail(makeFourPointRow());
        editValues();

        const dehydration = parameterRow('Dehydration');
        const [, notSedated] = dehydration.getAllByRole('combobox');
        userEvent.selectOptions(notSedated, '1');
        expect(parameterRow('Dehydration').getByText('NS')).toBeInTheDocument();

        userEvent.type(dehydration.getByRole('textbox'), 'Was not sedated');
        userEvent.click(saveButton());

        await waitFor(() => expect(onSaved).toHaveBeenCalledTimes(1));
        expect(mockCorrect.mock.calls[0][1]).toEqual([
            expect.objectContaining({ field: 'Dehydration', notSedated: 1, reason: 'Was not sedated', value: null }),
        ]);
    });
});

describe('ObservationDetail, Found Dead on the 15-point form', () => {
    test('is just another value: the observation is still fully recorded', async () => {
        const onSaved = await renderDetail();
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        userEvent.selectOptions(parameterRow('Found Dead').getByRole('combobox'), '1');
        expect(parameterRow('Bleeding').getByRole('combobox')).toHaveValue('0');

        userEvent.type(parameterRow('Found Dead').getByRole('textbox'), 'Deceased box missed');
        userEvent.click(saveButton());

        await waitFor(() => expect(onSaved).toHaveBeenCalledTimes(1));
        expect(mockCorrect.mock.calls[0][1]).toEqual([
            expect.objectContaining({ field: 'FoundDead', reason: 'Deceased box missed', value: '1' }),
        ]);
    });
});

describe('ObservationDetail, husbandry', () => {
    test('shows Cage Cleaning and Water as words, N/A when empty, with no prior', async () => {
        mockFetchPrior.mockResolvedValue(makeRow({ lsid: 'prior', CageCleaning: 2 }));
        await renderDetail();
        await screen.findByRole('link', { name: 'Prior' });

        expect(parameterRow('Cage Cleaning').getByText('Cleaned')).toBeInTheDocument();
        expect(parameterRow('Cage Cleaning').queryByText('Changed')).not.toBeInTheDocument();
        expect(parameterRow('Water').getByText('N/A')).toBeInTheDocument();
    });

    test('is not scored', async () => {
        await renderDetail(makeRow({ CageCleaning: 2, Water: 2 }));

        expect(screen.getByText('Clinical Score:')).toHaveTextContent('Clinical Score: 0');
    });

    test('a change needs a reason, and N/A is sent as empty', async () => {
        const onSaved = await renderDetail();
        userEvent.click(screen.getByRole('button', { name: 'Edit Values' }));

        const cage = parameterRow('Cage Cleaning');
        userEvent.selectOptions(cage.getByRole('combobox'), 'N/A');
        expect(saveButton()).toBeDisabled();

        userEvent.type(cage.getByRole('textbox'), 'Not cleaned today');
        userEvent.click(saveButton());

        await waitFor(() => expect(onSaved).toHaveBeenCalledTimes(1));
        expect(mockCorrect.mock.calls[0][1]).toEqual([
            expect.objectContaining({ field: 'CageCleaning', reason: 'Not cleaned today', value: '' }),
        ]);
    });
});
