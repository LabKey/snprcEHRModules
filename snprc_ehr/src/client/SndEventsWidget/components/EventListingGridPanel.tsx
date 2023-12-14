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

interface EventListingProps {
    subjectIDs: string[]
}

export const EventListingGridPanelImpl: FC<EventListingProps> = memo((props: EventListingProps & InjectedQueryModels) => {
    const { subjectIDs, actions, queryModels } = props;

    const [showDialog, setShowDialog] = useState<string>('');
    const [eventID, setEventID] = useState<string>('');
    const [queryModel, setQueryModel] = useState<QueryModel>(queryModels[subjectIDs[0]]);

    useEffect(() => {
        (async () => {
            if (queryModels?.[subjectIDs[0]] && !queryModels[subjectIDs[0]].isLoading) {
                const {queryInfo} = queryModels[subjectIDs[0]];
                if (queryInfo) {
                    const queryCols = new ExtendedMap<string, QueryColumn>();
                    queryInfo.columns.forEach( (column, key) => {
                        if ((column.name === 'HTMLNarrative')) {
                            const htmlCol = new QueryColumn({...column, ...{"cell": htmlRenderer}});
                            queryCols.set(key, htmlCol);
                        } else if ((column.name === 'SubjectId')) {
                            const editCol = new QueryColumn({...column, ...{"cell": editButtonRenderer}});
                            queryCols.set(key, editCol);
                        } else if ((column.name === 'AdmitChargeId')) {
                            const admitCol = new QueryColumn({...column, ...{"cell": admitChargeIdPopoverRenderer}});
                            queryCols.set(key, admitCol);
                        } else {
                            queryCols.set(key, column);
                        }
                    });

                    const newQueryInfo = new QueryInfo({...queryInfo, ...{"columns": queryCols}});

                    // Update QueryModel with new QueryInfo
                    setQueryModel(
                        produce<QueryModel>(draft => {
                            Object.assign(draft, {...queryModels[subjectIDs[0]], ...{'queryInfo': newQueryInfo}});
                        })
                    );
                }
            }
        })()

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
            <div dangerouslySetInnerHTML={{__html: data.get('value')}} />
        );
    }

    const handleClick = (value) => {
        // Code to run when the button is clicked
        setEventID(value.toString());
        toggleDialog('edit');
    };

    const editButtonRenderer = (data, row) => {
        return (
            <div>
                <span>{data.get('value')} </span>
                <button className={"pencil-btn"} onClick={function() { handleClick(row.get('EventId').get('value')) }}>
                    <i className={"fa fa-pencil"}></i>
                </button>
            </div>
        );
    }

    const admitChargeIdPopoverRenderer = (data, row) => {
        const admitChargeId = data.get('value');
        const eventId = row.get('EventId').get('value');
        return (
            <AdmissionInfoPopover admitChargeId={admitChargeId} eventId={eventId} />
        )
    }

    /**
     * Render the custom buttons that will be displayed on the grid
     */
    const renderButtons = () => {
        return (
            <div className="manage-buttons">
                {<Button bsStyle={'success'} onClick={() => toggleDialog('create')}>
                    Create
                </Button>}
            </div>
        );
    };

    return (
        <div>
            {queryModel?.queryInfo && (
                <GridPanel model={queryModel}
                           title={"Events for Animal(s) " + subjectIDs.join(', ')}
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
                                     eventId={eventID}
                                     show={showDialog === 'edit'}
                />
            )}
            {showDialog === 'create' && (
                <ProcedureEntryModal show={showDialog === 'create'} onCancel={closeDialog} subjectIds={subjectIDs}/>
            )}

        </div>
    )
});

const EventListingGridPanelWithModels = withQueryModels<EventListingProps>(EventListingGridPanelImpl);

export const EventListingGridPanel: FC<EventListingProps> = memo((props: EventListingProps ) => {
    const { subjectIDs } = props;

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

