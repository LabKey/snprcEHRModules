import React from 'react'
import { TableGridPanelImpl } from '../components/TableGridPanel';
import { render, screen, fireEvent, cleanup, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import {
    initQueryGridState,
    makeTestActions,
    makeTestQueryModel,
    QueryInfo,
    SchemaQuery,
    User
} from '@labkey/components';
import { PermissionTypes, LabKey } from '@labkey/api'
import { SCHEMAS } from '../schemas';

/******************************************************
 * Necessary helper functions to set server context. These will be exported from @labkey/components in a later version.
 */
import { Map } from 'immutable';

declare let LABKEY: LabKey;

export function initMockServerContext(context: Partial<LabKey>): void {
    Object.assign(LABKEY, context);
}

export const initUnitTests = (metadata?: Map<string, any>, columnRenderers?: Map<string, any>): void => {
    initMockServerContext({
        container: {
            id: 'testContainerEntityId',
            title: 'Test Container',
            path: '/testContainer',
            formats: {
                dateFormat: 'yyyy-MM-dd',
                dateTimeFormat: 'yyyy-MM-dd HH:mm',
                numberFormat: null,
            },
            activeModules: ['Core', 'Query'], // add in the Ontology module if you want to test the Field Editor integrations
        },
        contextPath: '/labkey',
        user: TEST_USER_EDITOR
    });
    initQueryGridState(metadata, columnRenderers);
};

jest.mock('../actions');
/**
 *  TODO: Add actual renders to tests so that they properly check the components. Holding off on writing tests
 *  until there is a better established way to test the GridPanel components with RTL
 **/
const TEST_USER_EDITOR = new User({
    id: 1100,
    canDelete: true,
    canDeleteOwn: true,
    canInsert: true,
    canUpdate: true,
    canUpdateOwn: true,
    displayName: 'EditorDisplayName',
    isAdmin: false,
    isAnalyst: false,
    isDeveloper: false,
    isGuest: false,
    isRootAdmin: false,
    isSignedIn: true,
    isSystemAdmin: false,
    isTrusted: false,
    permissionsList: [
        PermissionTypes.Delete,
        PermissionTypes.Read,
        PermissionTypes.Insert,
        PermissionTypes.Update,
        PermissionTypes.ManagePicklists,
        PermissionTypes.ManageSampleWorkflows,
        PermissionTypes.ReadNotebooks,
        PermissionTypes.ReadDataClass,
        PermissionTypes.ReadAssay,
        PermissionTypes.ReadMedia,
    ],
});
const LOOKUP_SETS_SCHEMA_QUERY = new SchemaQuery(SCHEMAS.SND_TABLES.LOOKUP_SETS.schemaName, SCHEMAS.SND_TABLES.LOOKUP_SETS.queryName, 'test_view');

const PARENT_PROPS  = {
    table: 'LookupSets',
    rowIdName: 'LookupSetId',
    rowNameField: 'SetName',
    omittedColumns: ['label', 'description', 'container', 'createdby', 'created', 'modifiedby', 'modified', 'objectid'],
    displayColumns: ['lookupSetId', 'description', 'label', 'setName', 'isInUse'],
    schemaQuery: LOOKUP_SETS_SCHEMA_QUERY,
    title: 'Lookup Set',
    handleSelectedParentRow: jest.fn(),
    onChange: jest.fn(),
    filters: [],
    actions: makeTestActions(),
    queryModels: {
        'LookupSets': makeTestQueryModel(
            LOOKUP_SETS_SCHEMA_QUERY,
            QueryInfo.fromJsonForTests(
                {
                    name: SCHEMAS.SND_TABLES.LOOKUP_SETS.queryName,
                    schemaName: SCHEMAS.SND_TABLES.LOOKUP_SETS.schemaName,
                    views: [{name: 'test_view'}]
                },
                true
            ),
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
            new QueryInfo({}),
            {},
            [],
            0,
            'Lookups'
        )
    }
};

beforeEach( async () => {
    initQueryGridState();
    initUnitTests();
    await waitFor (() => {
        render(<TableGridPanelImpl {...PARENT_PROPS} />);
    })
})

afterEach(() => {
    cleanup();
})
describe('TableGridPanel Tests', () => {
    it ('renders the LookupSets GridPanel', async () => {
        await waitFor(() => {
            expect(screen.getByText('Lookup Sets - test_view')).toBeInTheDocument();
        });
    })
    it('renders the Lookups GridPanel on row selection', async () => {
        //render(<TableGridPanel {...CHILD_PROPS} />);
    })
    it('renders the Create Modal with row selected on Create button clicked for LookupSet',  async () => {
        fireEvent.click(screen.getByRole('button', {name: 'Create'}));
        await waitFor(() => {
            expect(screen.getByRole('document')).toBeInTheDocument();
        });

    })
    it('creates a new LookupSet on Modal confirm', async () => {
        fireEvent.click(screen.getByRole('button', {name: 'Create'}));
        fireEvent.change(screen.getByRole('textbox'), {target: {value: 'testSet'}})
        await waitFor(() => {
            expect(screen.getByRole('textbox').value).toBe('testSet')
        });

        //screen.debug(screen.getByRole('button', {name: 'Create Lookup Set'}))
        fireEvent.click(screen.getByRole('button', {name: 'Create Lookup Set'}))
        await waitFor(() => {
            expect(screen.getByRole('button', {name: 'Creating Lookup Set'})).toBeInTheDocument();
        });
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