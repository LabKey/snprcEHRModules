import React from 'react';
import { render, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import ObservationDetail from '../components/ObservationDetail';
import { correctObservation, fetchPriorObservation, ObservationRow } from '../api/observation';
import { SCORED_FIELDS } from '../constants/fields';

jest.mock('../api/observation', () => ({
    correctObservation: jest.fn(),
    fetchPriorObservation: jest.fn(),
    historyUrl: jest.fn(() => '#history'),
}));

const mockCorrect = correctObservation as jest.Mock;
const mockFetchPrior = fetchPriorObservation as jest.Mock;

// A complete observation with every scored field at 0 and every carry-over at No
const makeRow = (overrides: ObservationRow = {}): ObservationRow => {
    const row: ObservationRow = {
        lsid: 'lsid-1',
        Id: '12345',
        Location: 23.03,
        date: '2026/09/28 13:45:00',
        Comment: 'Quiet morning',
        'createdBy/DisplayName': 'observer',
    };
    SCORED_FIELDS.forEach(f => {
        row[f.name] = f.name === 'Stool' ? '0' : 0;
        if (f.carryOver) row[f.carryOver] = 0;
    });
    return { ...row, ...overrides };
};

// The table row for one parameter, so its value, carry-over and reason controls can be found by label
const parameterRow = (label: string) => within(screen.getByText(label).closest('tr'));

const renderDetail = async (row: ObservationRow = makeRow(), onSaved = jest.fn()) => {
    render(<ObservationDetail onSaved={onSaved} row={row} />);
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
