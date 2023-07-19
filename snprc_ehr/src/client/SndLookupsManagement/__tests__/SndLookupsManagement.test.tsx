import React from 'react'
import { SndLookupsManagement } from '../SndLookupsManagement';
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom'

describe('SndLookupsManagement', () => {
    it('renders the SndLookupsManagement page', () => {
        render(<SndLookupsManagement />);
        expect(screen.getByTestId('lookup-sets')).toBeInTheDocument();
        expect(screen.getByTestId('lookups')).toBeInTheDocument();
    })
})