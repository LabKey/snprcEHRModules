import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import BiocontainmentObservationReview from '../BiocontainmentObservationReview';
import { approveObservation, fetchObservation } from '../api/observation';

jest.mock('../api/observation', () => ({
    approveObservation: jest.fn(),
    fetchObservation: jest.fn(),
}));

// The real grid is a LabKey GridPanel; this stand-in exposes the callbacks the page gives it, and whether Approve is allowed
jest.mock('../components/ReviewGridPanel', () => ({
    ReviewGridPanel: ({ canApprove, onApprove, onFocus }) => (
        <div>
            <button onClick={() => onFocus('lsid-1')}>select lsid-1</button>
            <button onClick={() => onFocus('lsid-2')}>select lsid-2</button>
            <button onClick={() => onFocus(undefined)}>deselect</button>
            <button onClick={() => onApprove('lsid-1')}>approve lsid-1</button>
            <span>{canApprove ? 'approve enabled' : 'approve disabled'}</span>
        </div>
    ),
}));

jest.mock('../components/ObservationDetail', () => ({
    __esModule: true,
    default: ({ row, onEditingChange }) => (
        <div>
            <div>detail for {row.Id}</div>
            <button onClick={() => onEditingChange(true)}>start editing</button>
            <button onClick={() => onEditingChange(false)}>stop editing</button>
        </div>
    ),
}));

const mockApprove = approveObservation as jest.Mock;
const mockFetch = fetchObservation as jest.Mock;

const MODIFIED = '2026/11/09 10:15:00';

// The placeholder heading, not the instructions paragraph that starts with the same words
const placeholder = () => screen.queryByRole('heading', { name: /Select an observation to see the full record/ });

beforeEach(() => {
    jest.clearAllMocks();
    mockFetch.mockImplementation(lsid =>
        Promise.resolve({ Id: lsid === 'lsid-1' ? '11111' : '22222', lsid, modified: MODIFIED })
    );
    mockApprove.mockResolvedValue({});
});

test('shows the placeholder until an observation is selected', () => {
    render(<BiocontainmentObservationReview />);

    expect(placeholder()).toBeInTheDocument();
    expect(mockFetch).not.toHaveBeenCalled();
});

test('opens the selected observation', async () => {
    render(<BiocontainmentObservationReview />);

    userEvent.click(screen.getByText('select lsid-1'));

    expect(await screen.findByText('detail for 11111')).toBeInTheDocument();
    expect(mockFetch).toHaveBeenCalledWith('lsid-1');
});

test('closes the record when it is deselected', async () => {
    render(<BiocontainmentObservationReview />);
    userEvent.click(screen.getByText('select lsid-1'));
    await screen.findByText('detail for 11111');

    userEvent.click(screen.getByText('deselect'));

    expect(screen.queryByText('detail for 11111')).not.toBeInTheDocument();
    expect(placeholder()).toBeInTheDocument();
});

test('never shows a slower fetch for a record that is no longer selected', async () => {
    let resolveFirst: (row: object) => void;
    mockFetch.mockImplementationOnce(() => new Promise(resolve => (resolveFirst = resolve)));
    render(<BiocontainmentObservationReview />);

    userEvent.click(screen.getByText('select lsid-1'));
    userEvent.click(screen.getByText('select lsid-2'));
    await screen.findByText('detail for 22222');

    resolveFirst({ Id: '11111', lsid: 'lsid-1' });
    await waitFor(() => expect(screen.queryByText('detail for 11111')).not.toBeInTheDocument());
    expect(screen.getByText('detail for 22222')).toBeInTheDocument();
});

test('approving closes the record and confirms it', async () => {
    render(<BiocontainmentObservationReview />);
    userEvent.click(screen.getByText('select lsid-1'));
    await screen.findByText('detail for 11111');

    userEvent.click(screen.getByText('approve lsid-1'));

    expect(await screen.findByText('Observation approved.')).toBeInTheDocument();
    expect(mockApprove).toHaveBeenCalledWith('lsid-1', MODIFIED);
    expect(screen.queryByText('detail for 11111')).not.toBeInTheDocument();
    expect(placeholder()).toBeInTheDocument();
});

test('shows the server error and keeps the record open when approval is rejected', async () => {
    mockApprove.mockRejectedValue({ exception: 'This observation must be reviewed by someone other than its author' });
    render(<BiocontainmentObservationReview />);
    userEvent.click(screen.getByText('select lsid-1'));
    await screen.findByText('detail for 11111');

    userEvent.click(screen.getByText('approve lsid-1'));

    expect(
        await screen.findByText('This observation must be reviewed by someone other than its author')
    ).toBeInTheDocument();
    expect(screen.getByText('detail for 11111')).toBeInTheDocument();
});

test('shows the current version after an approval is rejected because the record changed', async () => {
    const CHANGED = '2026/11/09 10:20:00';
    mockFetch
        .mockResolvedValueOnce({ Id: '11111', lsid: 'lsid-1', modified: MODIFIED })
        .mockResolvedValueOnce({ Id: '11112', lsid: 'lsid-1', modified: CHANGED });
    mockApprove
        .mockRejectedValueOnce({ exception: 'This observation changed after you opened it. Check the current version and approve again.' })
        .mockResolvedValueOnce({});
    render(<BiocontainmentObservationReview />);
    userEvent.click(screen.getByText('select lsid-1'));
    await screen.findByText('detail for 11111');

    userEvent.click(screen.getByText('approve lsid-1'));

    expect(await screen.findByText('detail for 11112')).toBeInTheDocument();
    expect(screen.getByText(/This observation changed after you opened it/)).toBeInTheDocument();
    expect(mockFetch).toHaveBeenCalledTimes(2);

    // Approving again sends the version now on screen
    userEvent.click(screen.getByText('approve lsid-1'));
    expect(await screen.findByText('Observation approved.')).toBeInTheDocument();
    expect(mockApprove).toHaveBeenLastCalledWith('lsid-1', CHANGED);
});

test('Approve is disabled until the selected record has loaded', async () => {
    let resolveFetch: (row: object) => void;
    mockFetch.mockImplementationOnce(() => new Promise(resolve => (resolveFetch = resolve)));
    render(<BiocontainmentObservationReview />);
    expect(screen.getByText('approve disabled')).toBeInTheDocument();

    userEvent.click(screen.getByText('select lsid-1'));
    expect(screen.getByText('approve disabled')).toBeInTheDocument();

    resolveFetch({ Id: '11111', lsid: 'lsid-1', modified: MODIFIED });
    expect(await screen.findByText('approve enabled')).toBeInTheDocument();
});

test('Approve is disabled while a correction is being edited', async () => {
    render(<BiocontainmentObservationReview />);
    userEvent.click(screen.getByText('select lsid-1'));
    await screen.findByText('approve enabled');

    userEvent.click(screen.getByText('start editing'));
    expect(screen.getByText('approve disabled')).toBeInTheDocument();

    userEvent.click(screen.getByText('stop editing'));
    expect(screen.getByText('approve enabled')).toBeInTheDocument();
});

test('ignores an approval for a record that is not on screen', async () => {
    render(<BiocontainmentObservationReview />);
    userEvent.click(screen.getByText('select lsid-2'));
    await screen.findByText('detail for 22222');

    userEvent.click(screen.getByText('approve lsid-1'));

    expect(mockApprove).not.toHaveBeenCalled();
});

test('shows a JavaScript or network error message when there is no LabKey exception', async () => {
    mockApprove.mockRejectedValue(new Error('Failed to fetch'));
    render(<BiocontainmentObservationReview />);
    userEvent.click(screen.getByText('select lsid-1'));
    await screen.findByText('detail for 11111');

    userEvent.click(screen.getByText('approve lsid-1'));

    expect(await screen.findByText('Failed to fetch')).toBeInTheDocument();
});
