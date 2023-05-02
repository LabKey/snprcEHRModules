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
    queryModels: any,
    schemaQuery: SchemaQuery,
    title: string,
    filters: any[],
    handleSelectedParentRow?: (id: string, name: string) => void,
    onChange: (response: any) => void,
    onCreate: (response: any) => any
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

    useEffect(() => {
        (async () => {
            if (!parentId) {
                await initQueryModel();
            }
        })()
    }, []);

    useEffect(() => {
        (async () => {
            await setLastSelectedId();
        })()
    }, [queryModels[modelId]]);

    useEffect(() => {
        (async () => {
            if (parentId) {
                if (prevParentId !== parentId) {
                    await initQueryModel();
                } else {
                    actions.loadModel(parentId);
                }
            }
        })()

    }, [parentId]);

    useEffect(() => {
        (async () => {
            const currentRow = await getRow();
            setRow(currentRow);
        })()
    }, [selectedId]);

    useEffect(() => {
        if (handleSelectedParentRow) {
            handleSelectedParentRow(selectedId, row);
        }
    }, [row]);

    const getRow = async () => {
        const tableRow = await getTableRow(schemaQuery.schemaName, schemaQuery.queryName, rowIdName, +selectedId, +parentId);
        return tableRow['rows'][0];
    };

    const initQueryModel = async () => {
        const baseFilters = filters;
        actions.addModel(
            {
                id: parentId ?? table,
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
        setModelId(parentId ?? table);
    };

    const setLastSelectedId = async () => {
        const model = queryModels[modelId];
        if (!model || isLoading(model.selectionsLoadingState)) {
            return;
        }

        if (model.selectionsLoadingState === LoadingState.LOADED) {
            await updateLastSelectedId(await getLastSelectedId());

        }
    };

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

    const getLastSelectedId = async () => {
        const selectedIds: Set<string> = queryModels[modelId].selections;
        return selectedIds.size > 0 ? Array.from(selectedIds).pop() : undefined;
    };

    const toggleDialog = async (name: string, requiresSelection = false) => {
        if (requiresSelection && queryModels[modelId].hasSelections) {
            setShowDialog(undefined);
        } else {
            setShowDialog(name);
        }
    };

    const closeDialog = async () => {
        await toggleDialog(undefined);
    };

    const onCreateComplete = async (response: any) => {
        await closeDialog();
        await reloadModel();
        await onRowSelectionChange(queryModels[modelId], response.rows[0][toCamelCase(rowIdName)], true);
    };

    const onChangeComplete = async (response: any, resetSelection = true) => {
        await closeDialog();
        if (resetSelection) {
            await onRowSelectionChange(queryModels[modelId], undefined, response.id);
        }
        onChange(response);
        await reloadModel();

    };

    const reloadModel = async () => {
        actions.loadModel(modelId, true);
    };

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

    const renderButtons = () => {
        const model = queryModels[modelId];
        return (
            <div className="manage-buttons">
                {<Button bsStyle={'success'} onClick={() => toggleDialog('create')}>
                    Create
                </Button>}
                <ManageDropdownButton  id={table}>
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
                           allowFiltering={false}
                           allowSorting={true}
                           title={title + "s" + (parentName ? " for \'" + parentName + "\'" : "")}
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

const usePrevious = (value) => {
    const ref = useRef();
    useEffect(() => {
        ref.current = value;
    }, [value]);
    return ref.current;
};

const toCamelCase = (str: string) => {
    return str.replace(/(?:^\w|[A-Z]|\b\w)/g, function (word, index) {
        return index === 0 ? word.toLowerCase() : word.toUpperCase();
    }).replace(/\s+/g, '');
}