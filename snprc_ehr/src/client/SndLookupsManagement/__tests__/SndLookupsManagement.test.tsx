import React from 'react'
import { SndLookupsManagement } from '../SndLookupsManagement';
import { render } from '@testing-library/react'

describe('SndLookupsManagement', () => {
    it('renders the SndLookupsManagement page', () => {
        render(<SndLookupsManagement />);
    })
})