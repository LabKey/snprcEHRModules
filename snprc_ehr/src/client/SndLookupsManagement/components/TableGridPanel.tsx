import React, { FC, memo, useEffect, useMemo, useRef, useState } from 'react';
import {
    GridPanel,
    InjectedQueryModels,
    isLoading,
    LoadingState,
    ManageDropdownButton,
    QueryConfigMap,
    QueryModel,
    SchemaQuery,
    SelectionMenuItem,
    withQueryModels
} from '@labkey/components';


import { Button } from 'react-bootstrap';
import { CreateModal } from './CreateModal';
import { UpdateModal } from './UpdateModal';
import { DeleteModal } from './DeleteModal';
import { getTableRow } from '../actions';

interface TableProps {
    table: string,
    parentId?: string,
    rowIdName: string,
    parentIdName?: string,
    rowNameField: string,
    parentName?: string,
    omittedColumns: string[],
    displayColumns: string[],
    schemaQuery: SchemaQuery,
    title: string,
    filters: any[],
    handleSelectedParentRow?: (id: string, name: string) => void,
    onChange: (response: any) => void
}

export const TableGridPanelImpl: FC<TableProps> = memo((props: TableProps & InjectedQueryModels) => {
    const {
        actions,
        queryModels,
        parentId,
        rowIdName,
        rowNameField,
        parentIdName,
        parentName,
        omittedColumns,
        displayColumns,
        table,
        schemaQuery,
        title,
        filters,
        handleSelectedParentRow,
        onChange
    } = props;
    const [modelId, setModelId] = useState<string>(table);
    const [selectedId, setSelectedId] = useState<string>('');
    const [showDialog, setShowDialog] = useState<string>('');
    const [row, setRow] = useState<any>([]);
    const [isScrolling, setIsScrolling] = useState<boolean>(false);
    const prevParentId = usePrevious(parentId);

    /**
     * Set state for selected row id on table when new row is selected
     */
    useEffect(() => {
        (async () => {
            await setLastSelectedId().catch(error => console.error(error));
            await getRow().catch(error => console.error(error));
        })();
    }, [queryModels[modelId]]);

    /**
     * Load queryModel for child table when new row is selected in Parent table
     */
    useEffect(() => {
        (async () => {
            if (parentId) {
                if (prevParentId !== parentId) {
                    await initQueryModel().catch(error => console.error(error));
                } else {
                    actions.loadModel(parentId);
                }
            }
        })();

    }, [parentId]);
    
    /**
     * Invoke callback to set the page state when new row is selected and data retrieved
     */
    useEffect(() => {
        (async () => {
            if (handleSelectedParentRow) {
                handleSelectedParentRow(selectedId, row);
            }
            if (isScrolling) {
                await scroll();
                setIsScrolling(false);
            }
        })();
    }, [row]);


    /**
     * Get data for current row in state
     */
    const getRow = async () => {
        const currentRow = await getTableRow(schemaQuery.schemaName, schemaQuery.queryName,
            rowIdName, +selectedId, displayColumns).catch(error => console.error(error));
        if (currentRow) {
            setRow(currentRow['rows'][0]);
        }
    };

    /**
     * Initialize the queryModel for table depending on props being for parent (lookupSets) or child (lookups) table
     */
    const initQueryModel = async () => {
        const baseFilters = filters;
        actions.addModel(
            {
                id: table,
                schemaQuery: schemaQuery,
                baseFilters,
                omittedColumns: omittedColumns,
                bindURL: true
            },
            true,
            true
        );
        setModelId(table);
        actions.setMaxRows(table, 300);
    };

    /**
     * Set the last selected id for the queryModel
     */
    const setLastSelectedId = async () => {
        const model = queryModels[modelId];
        if (!model || isLoading(model.selectionsLoadingState)) {
            return;
        }

        if (model.selectionsLoadingState === LoadingState.LOADED) {
            await updateLastSelectedId(await getLastSelectedId()).catch(error => console.error(error));

        }
    };

    /**
     * Update the state for the last selected row id in the queryModel
     * @param id
     */
    const updateLastSelectedId = async (id: string) => {
        if (selectedId !== id) {
            if (id === undefined) {
                actions.clearSelections(modelId);
            } else {
                actions.replaceSelections(modelId, [id]);
            }
            setSelectedId(id);

        }
    };

    /**
     * Get the row id of the most recently selected row in the queryModel
     */
    const getLastSelectedId = async () => {
        const selectedIds: Set<string> = queryModels[modelId].selections;
        return selectedIds.size > 0 ? Array.from(selectedIds).pop() : undefined;
    };

    /**
     * Update the state for the toggleDialog value, called when a CRUD button is pressed.
     * @param name
     * @param requiresSelection
     */
    const toggleDialog = async (name: string, requiresSelection = false) => {
        if (requiresSelection && queryModels[modelId].hasSelections) {
            setShowDialog(undefined);
        } else {
            setShowDialog(name);
        }
    };

    /**
     * Update the state of toggleDialog to null when a CRUD modal is closed
     */
    const closeDialog = () => {
        const close = async () => {
            await toggleDialog(undefined);
        };

        try {
            close();
        }
        catch (e) {
            console.log(e);
        }
    };

    /**
     * Callback for completion of a create operation on a table
     * @param response
     */
    const onCreateComplete = async (response: any) => {
        closeDialog();
        try {
            await reloadModel();
            await onRowSelectionChange(queryModels[modelId], response.rows[0][toCamelCase(rowIdName)], true, response);
            onChange(response);
        }
        catch (error) {
            console.error(error);
        }
    };

    /**
     * Callback for completion of an update or delete operation on a table
     * @param response
     */
    const onChangeComplete = async (response: any) => {
        await closeDialog();
        let id: number;
        let checked: boolean;
        if (response.command === 'delete') {
            id = undefined;
            checked = false;
        } else {
            id = response.rows[0][toCamelCase(rowIdName)];
            checked = true;
        }
        try {
            await onRowSelectionChange(queryModels[modelId], id, checked, response);
            await reloadModel();
            onChange(response);
        }
        catch (error) {
            console.error(error);
        }
    };

    /**
     * Refresh the table queryModel, called when a new row is created/updated/deleted
     */
    const reloadModel = async () => {
        actions.loadModel(modelId, true);
    };

    /**
     * Change the selected row, called when a new row is created/updated/deleted
     * @param model
     * @param newId
     * @param checked
     */
    const onRowSelectionChange = async (model: QueryModel, newId: any, checked: boolean, response: any) => {
        let id;
        if (checked) {
            if (newId) {
                id = newId;
            } else if (model.hasSelections) {
                id = await getLastSelectedId().catch(error => console.error(error));
            }
        }
        await updateLastSelectedId(id).catch(error => console.error(error));
        if (response.command !== 'delete') {
            setIsScrolling(true);
        }
    };

    /**
     * Scroll to the newly selected element on a grid on create or update
     */
    const scroll = () => {
        const value = row['SetName'] ?? row['Value'];

        const rows = [...document.querySelectorAll('.ws-pre-wrap') as any];
        const rowIndex = rows.findIndex(a => a.textContent == value);
        const rowElement = rows[rowIndex - 9];

        const grids = [...document.querySelectorAll('.table-responsive') as any];
        const gridIndex = grids.findIndex(a => a.parentElement
            .parentElement
            .parentElement
            .parentElement
            .parentElement
            .className
            .startsWith((row['SetName']) ? 'lookupSets-grid' : 'lookups-grid')
        );
        const gridElement = grids[gridIndex];

        if (gridElement.scrollHeight > gridElement.clientHeight) {
            rowElement.scrollIntoView();
        }
    };

    /**
     * Render the custom buttons that will be displayed on the grid
     */
    const renderButtons = () => {
        const model = queryModels[modelId];
        return (
            <div className="manage-buttons">
                {<Button bsStyle={'success'} onClick={() => toggleDialog('create')}>
                    Create
                </Button>}
                <ManageDropdownButton id={table}>
                    <SelectionMenuItem id={'delete-menu-item'}
                                       text={'Delete'}
                                       queryModel={model}
                                       onClick={() => toggleDialog('delete')}/>
                    <SelectionMenuItem id={'edit-menu-item'}
                                       text={'Edit'}
                                       queryModel={model}
                                       onClick={() => toggleDialog('update')}/>
                </ManageDropdownButton>
            </div>
        );
    };

    return (
        <div>
            {queryModels[modelId] && queryModels[modelId].queryInfo && (
                <GridPanel actions={actions}
                           model={queryModels[modelId]}
                           loadOnMount={true}
                           highlightLastSelectedRow={true}
                           showPagination={false}
                           allowSelections={true}
                           allowFiltering={true}
                           allowSorting={true}
                           showExport={false}
                           title={title + 's' + (parentName ? ' for \'' + parentName + '\'' : '')}
                           ButtonsComponent={renderButtons}
                />
            )}
            {showDialog === 'create' && (
                <CreateModal onCancel={closeDialog}
                             onComplete={onCreateComplete}
                             show={showDialog === 'create'}
                             table={title}
                             schemaQuery={schemaQuery}
                             parentId={+parentId}
                />
            )}
            {showDialog === 'update' && (
                <UpdateModal onCancel={closeDialog}
                             onComplete={onChangeComplete}
                             show={showDialog === 'update'}
                             id={+selectedId}
                             table={title}
                             schemaQuery={schemaQuery}
                             rowIdName={rowIdName}
                             rowNameField={rowNameField}
                             row={row}
                             parentIdName={parentIdName}
                             parentId={+parentId}
                />
            )}
            {showDialog === 'delete' && (
                <DeleteModal onCancel={closeDialog}
                             onComplete={onChangeComplete}
                             id={+selectedId}
                             rowIdName={rowIdName}
                             row={row}
                             table={title}
                             schemaQuery={schemaQuery}
                             rowNameField={rowNameField}
                />
            )}
        </div>

    );

});

const TableGridPanelWithQueryModels = withQueryModels<TableProps>(TableGridPanelImpl);

export const TableGridPanel: FC<TableProps> = memo((props) => {
    const {schemaQuery, table} = props;

    const queryConfigs = useMemo<QueryConfigMap>(
        () => ({
            [table]: {
                schemaQuery, maxRows: 300
            },
        }),
        [schemaQuery]
    );

    // providing "key" to allow for reload on lsid change
    return <TableGridPanelWithQueryModels autoLoad queryConfigs={queryConfigs} {...props} />;
});

/**
 * Custom hook to get the previous state value
 * @param value
 */
const usePrevious = (value) => {
    const ref = useRef();
    useEffect(() => {
        ref.current = value;
    }, [value]);
    return ref.current;
};

/**
 * Convert a string to camelCase
 * @param str
 */
const toCamelCase = (str: string) => {
    return str.replace(/(?:^\w|[A-Z]|\b\w)/g, function (word, index) {
        return index === 0 ? word.toLowerCase() : word.toUpperCase();
    }).replace(/\s+/g, '');
};