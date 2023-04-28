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
    actions: Actions,
    omittedColumns: string[],
    queryModels: any,
    schemaQuery: SchemaQuery,
    title: string,
    filters: any[],
    handleSelectedParentRow?: (id: string) => void,
    onChange: (response: any) => void,
    onCreate: (response: any) => any
}

export const TableGridPanel: FC<TableProps> = memo((props: TableProps) => {
    const {
        actions,
        queryModels,
        parentId,
        rowIdName,
        parentIdName,
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
        if (!parentId) {
            initQueryModel();
            setLastSelectedId();
        }

    }, []);

    useEffect(() => {
        setLastSelectedId();

    }, [queryModels[modelId]]);

    useEffect(() => {
        if (parentId) {
            if (prevParentId !== parentId) {
                initQueryModel();
            } else {
                actions.loadModel(parentId);
            }
        }
    }, [parentId]);

    useEffect(() => {
        const fetchData = async () => {
            await getRow();
        };
        fetchData();

    }, [selectedId]);

    const getRow = async () => {
        const tableRow = await getTableRow(schemaQuery.schemaName, schemaQuery.queryName, +selectedId, +parentId);
        setRow(tableRow['rows'].find(row => row[rowIdName] === +selectedId));
    };

    const initQueryModel = () => {
        const baseFilters = filters;
        actions.addModel(
            {
                id: parentId ? parentId : table,
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
        setModelId(parentId ? parentId : table);
    };

    const setLastSelectedId = (): void => {
        const model = queryModels[modelId];
        if (!model || isLoading(model.selectionsLoadingState)) {
            return;
        }

        if (model.selectionsLoadingState === LoadingState.LOADED) {
            updateLastSelectedId(getLastSelectedId());


        }

    };

    const updateLastSelectedId = (id: string) => {
        if (selectedId !== id) {
            if (id === undefined) {
                actions.clearSelections(modelId);
            } else {
                actions.replaceSelections(modelId, [id]);
            }
            setSelectedId(id);
            if (handleSelectedParentRow) {
                handleSelectedParentRow(id);
            }
        }
    };

    const getLastSelectedId = (): string => {
        const selectedIds: Set<string> = queryModels[modelId].selections;
        return selectedIds.size > 0 ? Array.from(selectedIds).pop() : undefined;
    };

    const toggleDialog = (name: string, requiresSelection = false): void => {
        if (requiresSelection && queryModels[modelId].hasSelections) {
            setShowDialog(undefined);
        } else {
            setShowDialog(name);
        }
    };

    const closeDialog = (): void => {
        toggleDialog(undefined);
    };

    const onCreateComplete = (response: any): void => {
        closeDialog();
        reloadModel();
        onRowSelectionChange(queryModels[modelId], response.rows[0][toCamelCase(rowIdName)], true);
    };

    const onChangeComplete = (response: any, resetSelection = true): void => {
        closeDialog();
        if (resetSelection) {
            onRowSelectionChange(queryModels[modelId], undefined, response.id);
        }
        onChange(response);
        reloadModel();

    };

    const reloadModel = (): void => {
        actions.loadModel(modelId, true);
    };

    const onRowSelectionChange = (model: QueryModel, newId: any, checked: boolean): void => {
        let id;

        if (checked) {
            if (newId) {
                id = newId;
            } else if (model.hasSelections) {
                id = getLastSelectedId();
            }
        }
        updateLastSelectedId(id);
    };

    const renderButtons = () => {
        const model = queryModels[modelId];
        return (
            <div className="manage-buttons">
                {<Button bsStyle={'success'} onClick={() => toggleDialog('create')}>Create</Button>}
                <ManageDropdownButton  id={table}>
                    <SelectionMenuItem id={'delete-menu-item'} text={'Delete'} queryModel={model}
                                       onClick={() => toggleDialog('delete')}/>
                    <SelectionMenuItem id={'edit-menu-item'} text={'Edit'} queryModel={model}
                                       onClick={() => toggleDialog('update')}/>
                </ManageDropdownButton>

            </div>
        );
    };

    return (
        <>
            {queryModels[modelId] && (
                <GridPanel actions={actions}
                           model={queryModels[modelId]}
                           loadOnMount={true}
                           highlightLastSelectedRow={true}
                           showPagination={false}
                           allowSelections={true}
                           allowFiltering={false}
                           allowSorting={true}
                           title={title}
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
                         row={row}/>
            )}
            {showDialog === 'update' && (
            <UpdateModal onCancel={closeDialog}
                         onComplete={onChangeComplete}
                         show={showDialog === 'update'}
                         id={+selectedId}
                         table={title}
                         schemaQuery={schemaQuery}
                         parentId={+parentId}
                         rowIdName={rowIdName}
                         row={row}
            parentIdName={parentIdName}/>
            )}
            {showDialog === 'delete' && (
                <DeleteModal onCancel={closeDialog}
                             onComplete={onChangeComplete}
                             id={+selectedId}
                             rowIdName={rowIdName}
                             row={row}
                             table={title}
                             schemaQuery={schemaQuery}/>

            )}
        </>

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