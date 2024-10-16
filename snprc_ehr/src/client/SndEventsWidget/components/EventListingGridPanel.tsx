import React, { FC, memo, useEffect, useMemo, useState } from 'react';
import {
    ExtendedMap,
    GridPanel,
    InjectedQueryModels,
    QueryColumn, QueryConfigMap, QueryInfo, QueryModel,
    withQueryModels
} from '@labkey/components';
import { Button } from 'react-bootstrap';
import { Filter } from '@labkey/api';
import { SCHEMAS } from '../schemas';
import { produce } from 'immer';
import { ProcedureEntryModal } from './ProcedureEntryModal';
import { AdmissionInfoPopover } from './AdmissionInfoPopover';
import { DeleteModal } from './DeleteModal';

interface EventListingProps {
    subjectIDs: string[],
    onChange: (message: string, status: string) => any,
    onError: (message: string) => any,
    hasWritePermission: boolean
}

export const EventListingGridPanelImpl: FC<EventListingProps> = memo((props: EventListingProps & InjectedQueryModels) => {
    const {subjectIDs, actions, queryModels, onChange, onError, hasWritePermission} = props;

    const [showDialog, setShowDialog] = useState<string>('');
    const [eventID, setEventID] = useState<string>('');
    const [queryModel, setQueryModel] = useState<QueryModel>(queryModels[subjectIDs[0]]);

    useEffect(() => {
        (async () => {
            if (queryModels?.[subjectIDs[0]] && !queryModels[subjectIDs[0]].isLoading) {
                const {queryInfo} = queryModels[subjectIDs[0]];
                if (queryInfo) {
                    const queryCols = new ExtendedMap<string, QueryColumn>();
                    queryInfo.columns.forEach((column, key) => {
                        if ((column.name === 'HTMLNarrative')) {
                            const htmlCol = new QueryColumn({...column, ...{'cell': htmlRenderer}});
                            queryCols.set(key, htmlCol);
                        } else if ((column.name === 'SubjectId')) {
                            const editCol = new QueryColumn({...column, ...{'cell': editButtonRenderer}});
                            queryCols.set(key, editCol);
                        } else if ((column.name === 'AdmitChargeId')) {
                            const admitCol = new QueryColumn({...column, ...{'cell': admitChargeIdPopoverRenderer}});
                            queryCols.set(key, admitCol);
                        } else {
                            queryCols.set(key, column);
                        }
                    });

                    const newQueryInfo = new QueryInfo({...queryInfo, ...{'columns': queryCols}});

                    // Update QueryModel with new QueryInfo
                    setQueryModel(
                        produce<QueryModel>(draft => {
                            Object.assign(draft, {...queryModels[subjectIDs[0]], ...{'queryInfo': newQueryInfo}});
                        })
                    );
                }
            }
        })();

    }, [queryModels[subjectIDs[0]]]);


    const toggleDialog = async (name: string, requiresSelection = false) => {
        if (requiresSelection && queryModels[subjectIDs[0]].hasSelections) {
            setShowDialog(undefined);
        } else {
            setShowDialog(name);
        }
    };

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

    const htmlRenderer = (data) => {
        return (
            <div dangerouslySetInnerHTML={{__html: data.get('value')}}/>
        );
    };

    const handleClick = (value, isDelete: boolean) => {
        // Code to run when the button is clicked
        setEventID(value.toString());
        if (isDelete) {
            toggleDialog('delete');
        } else {
            toggleDialog('edit');
        }
    };

    const handleCloseUpdateModal = (message?: string, status?: string) => {
        if (message && status) {
            actions.loadModel(subjectIDs[0]);
            closeDialog();
            onChange(message, status);
        } else if (message) {
            closeDialog();
            onError(message);
        }
    };

    const editButtonRenderer = (data, row) => {
        return (
            <div>
                <span>{data.get('value')} </span>
                {hasWritePermission && (
                    <button className={'pencil-btn'} title="Edit" onClick={function () {
                        handleClick(row.get('EventId').get('value'), false);
                    }}>
                        <i className={'fa fa-pencil'}></i>
                    </button>
                )}
                {hasWritePermission && (
                    <button className={'trash-btn'} title="Delete" onClick={function () {
                        handleClick(row.get('EventId').get('value'), true);
                    }}>
                        <i className={'fa fa-trash'}></i>
                    </button>
                )}
            </div>
        );
    };

    const admitChargeIdPopoverRenderer = (data, row) => {
        const admitChargeId = data.get('value');
        const eventId = row.get('EventId').get('value');
        return (
            <AdmissionInfoPopover admitChargeId={admitChargeId} eventId={eventId}/>
        );
    };

    /**
     * Render the custom buttons that will be displayed on the grid
     */
    const renderButtons = () => {
        return (
            <div className="manage-buttons">
                {<Button disabled={!hasWritePermission || subjectIDs.length != 1 || subjectIDs[0] == ""} bsStyle={'success'}
                         onClick={() => toggleDialog('create')}>
                    New
                </Button>}
            </div>
        );
    };

    return (
        <div>
            {queryModel?.queryInfo && (
                <GridPanel model={queryModel}
                           title={'Events for Animal(s) ' + subjectIDs.join(', ')}
                           actions={actions}
                           highlightLastSelectedRow={true}
                           showPagination={true}
                           loadOnMount={true}
                           allowSelections={false}
                           allowFiltering={true}
                           allowSorting={true}
                           allowViewCustomization={true}
                           showSearchInput={true}
                           showExport={true}
                           ButtonsComponent={renderButtons}
                />
            )}
            {showDialog === 'edit' && (
                <ProcedureEntryModal onCancel={closeDialog}
                                     onError={handleCloseUpdateModal}
                                     onComplete={handleCloseUpdateModal}
                                     eventId={eventID}
                                     show={showDialog === 'edit'}
                />
            )}
            {showDialog === 'create' && (
                <ProcedureEntryModal show={showDialog === 'create'}
                                     onCancel={closeDialog}
                                     onError={handleCloseUpdateModal}
                                     onComplete={handleCloseUpdateModal}
                                     subjectId={subjectIDs[0]}/>
            )}
            {showDialog === 'delete' && (
                <DeleteModal onCancel={closeDialog}
                             onComplete={handleCloseUpdateModal}
                             onError={handleCloseUpdateModal}
                             eventId={eventID}/>
            )}

        </div>
    );
});

const EventListingGridPanelWithModels = withQueryModels<EventListingProps>(EventListingGridPanelImpl);

export const EventListingGridPanel: FC<EventListingProps> = memo((props: EventListingProps) => {
    const {subjectIDs} = props;

    const queryConfigs: QueryConfigMap = useMemo(
        () => ({
            [subjectIDs[0]]: {
                id: subjectIDs[0],
                baseFilters: [Filter.create('SubjectId', subjectIDs, Filter.Types.IN)],
                schemaQuery: SCHEMAS.SND_QUERIES.PROCEDURES,
                bindURL: true,
                maxRows: 100,
                includeTotalCount: true,
            },
        }),
        [subjectIDs]
    );

    return <EventListingGridPanelWithModels autoLoad key={subjectIDs[0]} queryConfigs={queryConfigs} {...props}/>;
});

