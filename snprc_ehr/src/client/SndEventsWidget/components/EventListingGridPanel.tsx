import React, { FC, memo, useEffect, useState } from 'react';
import { Button } from 'react-bootstrap';
import {
    GridPanel,
    InjectedQueryModels, isLoading, LoadingState,
    ManageDropdownButton,
    SelectionMenuItem,
    withQueryModels
} from '@labkey/components';
import { Filter } from '@labkey/api';
import { SCHEMAS } from '../schemas';
import { ProcedureEntryModal } from './ProcedureEntryModal';

interface EventListingProps {
    subjectID: string
}

export const EventListingGridPanelImpl: FC<EventListingProps> = memo((props: EventListingProps & InjectedQueryModels) => {
    const { subjectID, actions, queryModels } = props;

    const [showDialog, setShowDialog] = useState<string>('');
    const [selectedId, setSelectedId] = useState<string>('');

    useEffect(() => {
        initQueryModel();
    }, []);

    useEffect(() => {
        (async () => {
            await setLastSelectedId().catch(error => console.error(error));
        })();
    }, [queryModels[subjectID]]);

    const initQueryModel = () => {
        const baseFilters = [Filter.create('SubjectId', subjectID)];
        actions.addModel(
            {
                id: subjectID,
                baseFilters,
                schemaQuery: SCHEMAS.SND_QUERIES.PROCEDURES,
                bindURL: true
            },
            true,
            true
        );
    };

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
            {queryModels[subjectID] && (
                <GridPanel model={queryModels[subjectID]}
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

export const EventListingGridPanel = withQueryModels<EventListingProps>(EventListingGridPanelImpl);