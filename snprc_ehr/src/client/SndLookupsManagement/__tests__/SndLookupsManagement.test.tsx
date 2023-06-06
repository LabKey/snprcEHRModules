import React from 'react'
import { SndLookupsManagementImpl } from '../SndLookupsManagement';
import { render } from '@testing-library/react'
import { makeTestQueryModel, makeTestActions, QueryInfo } from '@labkey/components';
import { SCHEMAS } from '../schemas';

const queryModelProps = {
    actions: makeTestActions(),
    queryModels: {
        'LookupSets': makeTestQueryModel(
            SCHEMAS.SND_TABLES.LOOKUP_SETS,
            new QueryInfo(),
            {},
            [],
            0,
            'LookupSets'
        ),
        'Lookups': makeTestQueryModel(
            SCHEMAS.SND_TABLES.LOOKUPS,
            new QueryInfo(),
            {},
            [],
            0,
            'Lookups'
        )
    }
}

describe('SndLookupsManagement', () => {
    it('renders the SndLookupsManagement page', () => {
        render(<SndLookupsManagementImpl {...queryModelProps}/>);
    })
})