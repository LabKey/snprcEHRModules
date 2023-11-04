import React, { FC, memo, useEffect, useMemo, useState } from 'react';
import {
    ExtendedMap,
    GridPanel,
    InjectedQueryModels,
    QueryColumn, QueryConfigMap, QueryInfo, QueryModel,
    withQueryModels
} from '@labkey/components';
import { Filter } from '@labkey/api';
import { SCHEMAS } from '../schemas';
import { produce } from 'immer';
import { Popover, OverlayTrigger } from 'react-bootstrap';
import { ProcedureEntryModal } from './ProcedureEntryModal';
import { getTableRow } from '../actions';

interface EventListingProps {
    subjectID: string
}

export const EventListingGridPanelImpl: FC<EventListingProps> = memo((props: EventListingProps & InjectedQueryModels) => {
    const { subjectID, actions, queryModels } = props;

    const [showDialog, setShowDialog] = useState<string>('');
    const [eventID, setEventID] = useState<string>('');
    const [admitEventId, setAdmitEventID] = useState<string>('');
    const [displayInfo, setDisplayInfo] = useState<string[]>([]);
    const [queryModel, setQueryModel] = useState<QueryModel>(queryModels[subjectID]);


    useEffect(() => {
        (async () => {
            if (queryModels?.[subjectID] && !queryModels[subjectID].isLoading) {
                const {queryInfo} = queryModels[subjectID];
                if (queryInfo) {
                    const queryCols = new ExtendedMap<string, QueryColumn>();
                    queryInfo.columns.forEach( (column, key) => {
                        if ((column.name === 'HTMLNarrative')) {
                            const htmlCol = new QueryColumn({...column, ...{"cell": htmlRenderer}});
                            queryCols.set(key, htmlCol);
                        } else if ((column.name === 'EventId')) {
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
                            Object.assign(draft, {...queryModels[subjectID], ...{'queryInfo': newQueryInfo}});
                        })
                    );
                }
            }
        })()

    }, [queryModels[subjectID]]);

    useEffect(() => {
        (async() => {
            console.log(admitEventId)
            await getAdmitData();
        })();
    }, [admitEventId]);

    const toggleDialog = async (name: string, requiresSelection = false) => {
        if (requiresSelection && queryModels[subjectID].hasSelections) {
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

    const editButtonRenderer = (data) => {
        return (
            <button onClick={function() { handleClick(data.get('value')) }}>Edit</button>
        );
    }

    const admitChargeIdPopoverRenderer = (data, row) => {
        const handleEnter = async () => {
            const id = row.get('EventId').get('value');
            setAdmitEventID(id);
            //await getAdmitData(id);
        }
        return (
            <OverlayTrigger placement="left" overlay={renderPopover} onEnter={handleEnter} shouldUpdatePosition={true}>
                <span>{data.get('value')}</span>
            </OverlayTrigger>
        )
    }

    const getAdmitData = async () => {
        const info = (await getTableRow('snd', 'AdmitChargeIdProtocolInfo', 'EventId', admitEventId, []))['rows'][0];
        console.log(info)
        let display: string[] = [];
        if (info['AdmitId'] != null) {
            display.push('Admit ID: ' + info['AdmitId'],
                'Diagnosis: ' + info['Diagnosis'],
                'Admitting complaint: ' + info['AdmittingComplaint'],
                'Admission date: ' + info['AdmitDate']);

            if (info['ReleaseDate'] != null) {
                display.push('Release date: ' + info['ReleaseDate'])
            }
            if (info['Resolution'] != null) {
                display.push('Resolution ' + info['Resolution'])
            }
        } else {
            display.push('Charge ID: ' + info['ChargeId'])
            if (info['Protocol'] != null) {
                display.push('IACUC #: ' + info['Protocol'],
                    'IACUC Description: ' + info['Description'],
                    //'IACUC Assignment Date: ' + info['AssignmentDate'],
                    'Supervising Vet: ' + info['Veterinarian']);
            } else {
                display.push('Description: ' + info['Title'])
            }
        }
        setDisplayInfo(display);
    }

    const renderPopover = (
        <Popover className={"charge-id-popover"} id={"charge-id-popover"} >
            <div>
                <h4>Admission Information</h4>
                {displayInfo.map((d, i) => {
                    return <div key={i}>{d}</div>
                })}
            </div>
        </Popover>
    )

    return (
        <div>
            {queryModel?.queryInfo && (
                <GridPanel model={queryModel}
                           title={"Events for Animal " + subjectID}
                           actions={actions}
                           highlightLastSelectedRow={true}
                           showPagination={false}
                           loadOnMount={true}
                           allowSelections={false}
                           allowFiltering={true}
                           allowSorting={true}
                           allowViewCustomization={false}
                           showSearchInput={true}
                           showExport={false}
                />
            )}
            {showDialog === 'edit' && (
                <ProcedureEntryModal onCancel={closeDialog}
                                     eventId={eventID}
                                     show={showDialog === 'edit'}
                />
            )}

        </div>
    )
});

const EventListingGridPanelWithModels = withQueryModels<EventListingProps>(EventListingGridPanelImpl);

export const EventListingGridPanel: FC<EventListingProps> = memo((props: EventListingProps ) => {
    const { subjectID } = props;

    const queryConfigs: QueryConfigMap = useMemo(
        () => ({
            [subjectID]: {
                id: subjectID,
                baseFilters: [Filter.create('SubjectId', subjectID)],
                schemaQuery: SCHEMAS.SND_QUERIES.PROCEDURES,
                bindURL: true,
                maxRows: 1000
            },
        }),
        [subjectID]
    );

    return <EventListingGridPanelWithModels autoLoad key={subjectID} queryConfigs={queryConfigs} {...props}/>;
});