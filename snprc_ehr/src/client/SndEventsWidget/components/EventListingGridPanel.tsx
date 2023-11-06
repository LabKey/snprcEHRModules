import React, { FC, memo, useEffect, useMemo, useState } from 'react';
import { Button } from 'react-bootstrap';
import {
    ExtendedMap,
    GridPanel,
    InjectedQueryModels, isLoading, LoadingState,
    ManageDropdownButton, QueryColumn, QueryConfigMap, QueryInfo, QueryModel,
    SelectionMenuItem,
    withQueryModels
} from '@labkey/components';
import { Filter } from '@labkey/api';
import { SCHEMAS } from '../schemas';
import { produce } from 'immer';
import { ProcedureEntryModal } from './ProcedureEntryModal';

interface EventListingProps {
    subjectID: string
}

const htmlRenderer = (data) => {
    return (
        <div dangerouslySetInnerHTML={{__html: data.get('value')}} />
    );
}

const handleClick = (value) => {
    // Code to run when the button is clicked
    alert('Button clicked for eventId: ' + value);
};

const editButtonRenderer = (data) => {
    return (
        <button onClick={function() { handleClick(data.get('value')) }}>Edit</button>
    );
}

export const EventListingGridPanelImpl: FC<EventListingProps> = memo((props: EventListingProps & InjectedQueryModels) => {
    const { subjectID, actions, queryModels } = props;

    const [showDialog, setShowDialog] = useState<string>('');
    const [selectedId, setSelectedId] = useState<string>('');
    const [queryModel, setQueryModel] = useState<QueryModel>(queryModels[subjectID]);

    useEffect(() => {
        (async () => {
            await setLastSelectedId().catch(error => console.error(error));
        })();
        console.log('queryModels', queryModels[subjectID]);
        if (queryModels?.[subjectID] && !queryModels[subjectID].isLoading) {
            const {queryInfo} = queryModels[subjectID];

            if (queryInfo) {
                const queryCols = new ExtendedMap<string, QueryColumn>();
                queryInfo.columns.forEach((column, key) => {
                    if ((column.name === 'HtmlNarrative')) {
                        const htmlCol = new QueryColumn({...column, ...{"cell": htmlRenderer}});
                        queryCols.set(key, htmlCol);
                    }
                    else if ((column.name === 'EventId')) {
                        const editCol = new QueryColumn({...column, ...{"cell": editButtonRenderer}});
                        queryCols.set(key, editCol);
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

    }, [queryModels[subjectID]]);

    console.log(queryModels[subjectID])

    // useEffect(() => {
    //     (async () => {
    //         await setLastSelectedId().catch(error => console.error(error));
    //     })();
    // }, [queryModels[subjectID]]);

    // const initQueryModel = () => {
    //     const baseFilters = [Filter.create('SubjectId', subjectID)];
    //     actions.addModel(
    //         {
    //             id: subjectID,
    //             baseFilters,
    //             schemaQuery: SCHEMAS.SND_QUERIES.PROCEDURES,
    //             bindURL: true
    //         },
    //         true,
    //         true
    //     );
    // };

    /**
     * Set the last selected id for the queryModel
     */
    const setLastSelectedId = async () => {
        const model = queryModels[subjectID];
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
                actions.clearSelections(subjectID);
            } else {
                actions.replaceSelections(subjectID, [id]);
            }
            setSelectedId(id);

        }
    };

    /**
     * Get the row id of the most recently selected row in the queryModel
     */
    const getLastSelectedId = async () => {
        const selectedIds: Set<string> = queryModels[subjectID].selections;
        return selectedIds.size > 0 ? Array.from(selectedIds).pop() : undefined;
    };

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

    const renderButtons = () => {
        const model = queryModels[subjectID];
        return(
            <div>
                <ManageDropdownButton id={''}>
                    <SelectionMenuItem id={'edit-menu-item'}
                                       text={'Edit'}
                                       queryModel={model}
                                       onClick={() => toggleDialog('edit')}/>
                </ManageDropdownButton>
            </div>
        );
    }

    return (
        <div>
            {queryModel?.queryInfo && && (
                <GridPanel model={queryModel}
                           actions={actions}
                           highlightLastSelectedRow={true}
                           showPagination={false}
                           loadOnMount={true}
                           allowSelections={true}
                           allowFiltering={false}
                           allowSorting={true}
                           allowViewCustomization={false}
                           showSearchInput={false}
                           showExport={false}
                           ButtonsComponent={renderButtons}
                />
            )}
            {showDialog === 'edit' && (
                <ProcedureEntryModal onCancel={closeDialog}
                                     eventId={selectedId}
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
                bindURL: true
            },
        }),
        [subjectID]
    );

    return <EventListingGridPanelWithModels autoLoad key={subjectID} queryConfigs={queryConfigs} {...props}/>;
});