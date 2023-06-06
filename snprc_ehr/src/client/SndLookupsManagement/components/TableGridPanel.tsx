import {
    Actions,
    GridPanel,
    isLoading, LoadingState,
    ManageDropdownButton, QueryModel,
    SchemaQuery,
    SelectionMenuItem
} from '@labkey/components';
import React, { FC, memo, useEffect, useRef, useState } from 'react';
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
    actions: Actions,
    omittedColumns: string[],
    displayColumns: string[],
    queryModels: any,
    schemaQuery: SchemaQuery,
    title: string,
    filters: any[],
    handleSelectedParentRow?: (id: string, name: string) => void,
    onChange: (response: any) => void
}

export const TableGridPanel: FC<TableProps> = memo((props: TableProps) => {
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
    const [modelId, setModelId] = useState<string>('');
    const [selectedId, setSelectedId] = useState<string>('');
    const [showDialog, setShowDialog] = useState<string>('');
    const [row, setRow] = useState<any>([]);
    const prevParentId = usePrevious(parentId);

    /**
     * Create initial queryModel for parent (lookupSet) table grid
     */
    useEffect(() => {
        (async () => {
            if (!parentId) {
                await initQueryModel();
            }
        })();
    }, []);

    /**
     * Set state for selected row id on table when new row is selected
     */
    useEffect(() => {
        (async () => {
            await setLastSelectedId();
        })();
    }, [queryModels[modelId]]);

    /**
     * Load queryModel for child table when new row is selected in Parent table
     */
    useEffect(() => {
        (async () => {
            if (parentId) {
                if (prevParentId !== parentId) {
                    await initQueryModel();
                } else {
                    actions.loadModel(parentId);
                }
            }
        })();

    }, [parentId]);

    /**
     * Get the row data on new selected row on table
     */
    useEffect(() => {
        (async () => {
            await getRow();
        })();
    }, [selectedId]);

    /**
     * Invoke callback to set the page state when new row is selected and data retrieved
     */
    useEffect(() => {
        if (handleSelectedParentRow) {
            handleSelectedParentRow(selectedId, row);
        }
    }, [row]);

    /**
     * Get data for current row in state
     */
    const getRow = async () => {
        const currentRow = await getTableRow(schemaQuery.schemaName, schemaQuery.queryName, rowIdName, +selectedId, displayColumns);
        setRow(currentRow['rows'][0]);
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
        if (!parentId) {
            actions.setMaxRows(table, 300);
        }
        setModelId(table);
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
            await updateLastSelectedId(await getLastSelectedId());

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
    const closeDialog = async () => {
        await toggleDialog(undefined);
    };

    /**
     * Callback for completion of a create operation on a table
     * @param response
     */
    const onCreateComplete = async (response: any) => {
        await closeDialog();
        await reloadModel();
        await onRowSelectionChange(queryModels[modelId], response.rows[0][toCamelCase(rowIdName)], true);
        onChange(response);
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
        await onRowSelectionChange(queryModels[modelId], id, checked);
        await reloadModel();
        onChange(response);
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
    const onRowSelectionChange = async (model: QueryModel, newId: any, checked: boolean) => {
        let id;
        if (checked) {
            if (newId) {
                id = newId;
            } else if (model.hasSelections) {
                id = await getLastSelectedId();
            }
        }
        await updateLastSelectedId(id);
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
            {queryModels[modelId] && (
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