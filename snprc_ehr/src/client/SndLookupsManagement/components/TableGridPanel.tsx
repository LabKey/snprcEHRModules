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

interface TableProps {
    table: string,
    parentId?: string,
    rowIdName: string,
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
    const prevParentId = usePrevious(parentId);

    useEffect(() => {
        if (!parentId) {
            initQueryModel();
            setLastSelectedId();
        }
    }, []);

    useEffect(() => {
        setLastSelectedId();
    }, [queryModels[table]]);

    useEffect(() => {
        if (parentId) {
            if (prevParentId !== parentId) {
                initQueryModel();
            } else {
                actions.loadModel(parentId);
            }
        }
    }, [parentId]);

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
        onRowSelectionChange(queryModels[modelId], undefined, false);
        reloadModel();
    };

    const onChangeComplete = (response: any, resetSelection = true): void => {
        closeDialog();
        if (resetSelection) {
            onRowSelectionChange(queryModels[modelId], undefined, false);
        }
        onChange(response);
        reloadModel();
    };

    const reloadModel = (): void => {
        actions.loadModel(modelId, true);
    };

    const onRowSelectionChange = (model: QueryModel, row: any, checked: boolean): void => {
        let selectedId;

        if (checked) {
            if (row) {
                selectedId = row.getIn([rowIdName, 'value']);
            } else if (model.hasSelections) {
                selectedId = getLastSelectedId();
            }
        }
        updateLastSelectedId(selectedId);
    };

    const renderButtons = () => {
        const model = queryModels[modelId];
        return (
            <div className="btn-group">
                {<Button bsStyle={'success'} onClick={() => toggleDialog('create')}>Create</Button>}
                <ManageDropdownButton id={table}>
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
                           title={title}
                           ButtonsComponent={renderButtons}
                />
            )}
            <CreateModal onCancel={closeDialog}
                         onComplete={onCreateComplete}
                         show={showDialog === 'create'}
                         table={title}
                         schemaQuery={schemaQuery}
                         parentId={+parentId}/>
            <UpdateModal onCancel={closeDialog}
                         onComplete={onChangeComplete}
                         show={showDialog === 'update'}
                         id={+selectedId}
                         table={title}
                         schemaQuery={schemaQuery}
                         parentId={+parentId}
                         rowIdName={rowIdName}/>
            {showDialog === 'delete' && (
                <DeleteModal onCancel={closeDialog}
                             onComplete={onChangeComplete}
                             id={+selectedId}
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