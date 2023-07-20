import React from 'react'
import { SndLookupsManagement } from '../SndLookupsManagement';
import { render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom'

describe('SndLookupsManagement',  () => {
    it('renders the SndLookupsManagement page', async () => {
        render(<SndLookupsManagement/>);
        await waitFor(() =>  {
            expect(screen.getByTestId('lookup-sets')).toBeInTheDocument();
            expect(screen.getByTestId('lookups')).toBeInTheDocument();
        })


    })
})