import React from 'react'
import { TableGridPanel } from '../../components/TableGridPanel';
import { render, screen } from '@testing-library/react';
import { initQueryGridState, makeTestActions, makeTestQueryModel, QueryInfo } from '@labkey/components';
import { SCHEMAS } from '../../schemas';

/**
 *  TODO: Add actual renders to tests so that they properly check the components. Holding off on writing tests
 *  until there is a better established way to test the GridPanel components with RTL
 **/

const PARENT_PROPS  = {
    table: 'LookupSets',
    rowIdName: 'LookupSetId',
    rowNameField: 'SetName',
    omittedColumns: ['label', 'description', 'container', 'createdby', 'created', 'modifiedby', 'modified', 'objectid'],
    displayColumns: ['lookupSetId', 'description', 'label', 'setName', 'isInUse'],
    schemaQuery: SCHEMAS.SND_TABLES.LOOKUP_SETS,
    title: 'Lookup Sets',
    handleSelectedParentRow: jest.fn(),
    onChange: jest.fn(),
    filters: [],
    actions: makeTestActions(),
    queryModels: {
        'LookupSets': makeTestQueryModel(
            SCHEMAS.SND_TABLES.LOOKUP_SETS,
            new QueryInfo(),
            {},
            [],
            0,
            'LookupSets'
        )
    }
};
const CHILD_PROPS = {
    table: 'Lookups',
    rowIdName: 'LookupId',
    rowNameField: 'Value',
    omittedColumns: ['label', 'description', 'container', 'createdby', 'created', 'modifiedby', 'modified', 'objectid'],
    displayColumns: ['lookupId', 'LookupSetId', 'value', 'displayable', 'sortOrder', 'isInUse'],
    schemaQuery: SCHEMAS.SND_TABLES.LOOKUPS,
    title: 'Lookup',
    parentIdName: 'LookupSetId',
    onChange: jest.fn(),
    filters: [],
    actions: makeTestActions(),
    queryModels: {
        'Lookups': makeTestQueryModel(
            SCHEMAS.SND_TABLES.LOOKUP_SETS,
            new QueryInfo(),
            {},
            [],
            0,
            'Lookups'
        )
    }
};

beforeAll(() => {
    initQueryGridState();
})

describe('TableGridPanel Tests', () => {
    it ('renders the LookupSets GridPanel', () => {
        //render(<TableGridPanel {...PARENT_PROPS} />);
    })
    it('renders the Lookups GridPanel on row selection', () => {
        //render(<TableGridPanel {...CHILD_PROPS} />);
    })
    it('renders the Create Modal with row selected on Create button clicked for LookupSet', () => {

    })
    it('creates a new LookupSet on Modal confirm', () => {

    })
    it('renders the LookupSet Edit Modal', () => {

    })
    it('Successfully submits edit on LookupSet', () => {

    })
    it('renders the LookupSet Delete Modal', () => {

    })
    it('successfully submits delete on LookupSet', () => {

    })
    it('renders the Create Modal with row selected on Create button clicked for Lookup', () => {

    })
    it('creates a new Lookup on Modal confirm', () => {

    })
    it('renders the Lookup Edit Modal', () => {

    })
    it('successfully submits edit on Lookup', () => {

    })
    it('renders the Lookup Delete Modal', () => {

    })
    it('successfully submits delete on Lookup', () => {

    })
})