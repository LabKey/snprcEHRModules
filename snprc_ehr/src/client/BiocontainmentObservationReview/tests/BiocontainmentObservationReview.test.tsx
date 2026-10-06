import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import BiocontainmentObservationReview from '../BiocontainmentObservationReview';
import { approveObservations, fetchObservation } from '../api/observation';

jest.mock('../api/observation', () => ({
    approveObservations: jest.fn(),
    fetchObservation: jest.fn(),
}));

// The real grid is a LabKey GridPanel; this stand-in exposes the two callbacks the page gives it
jest.mock('../components/ReviewGridPanel', () => ({
    ReviewGridPanel: ({ onApprove, onFocus }) => (
        <div>
            <button onClick={() => onFocus('lsid-1')}>select lsid-1</button>
            <button onClick={() => onFocus('lsid-2')}>select lsid-2</button>
            <button onClick={() => onFocus(undefined)}>deselect</button>
            <button onClick={() => onApprove('lsid-1')}>approve lsid-1</button>
        </div>
    ),
}));

jest.mock('../components/ObservationDetail', () => ({
    __esModule: true,
    default: ({ row }) => <div>detail for {row.Id}</div>,
}));

const mockApprove = approveObservations as jest.Mock;
const mockFetch = fetchObservation as jest.Mock;

// The placeholder heading, not the instructions paragraph that starts with the same words
const placeholder = () => screen.queryByRole('heading', { name: /Select an observation to see the full record/ });

beforeEach(() => {
    jest.clearAllMocks();
    mockFetch.mockImplementation(lsid => Promise.resolve({ Id: lsid === 'lsid-1' ? '11111' : '22222', lsid }));
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
    expect(mockApprove).toHaveBeenCalledWith(['lsid-1']);
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
