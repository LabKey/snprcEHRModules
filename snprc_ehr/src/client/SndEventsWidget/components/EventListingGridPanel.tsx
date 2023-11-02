import React, { FC, memo, useEffect, useState } from 'react';
import { GridPanel, InjectedQueryModels, withQueryModels } from '@labkey/components';
import { Filter } from '@labkey/api';
import { SCHEMAS } from '../schemas';

interface EventListingProps {
    subjectID: number
}

export const EventListingGridPanelImpl: FC<EventListingProps> = memo((props: EventListingProps & InjectedQueryModels) => {
    const { actions, queryModels } = props;

    const [subjectID, setSubjectID] = useState<string>('42409');

    useEffect(() => {
        initQueryModel();
    }, []);

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

    console.log(queryModels[subjectID])

    return (
        <div>
            {queryModels[subjectID] && (
                <GridPanel model={queryModels[subjectID]}
                           actions={actions}
                           highlightLastSelectedRow={true}
                           showPagination={false}
                           allowSelections={true}
                           allowFiltering={false}
                           allowSorting={true}
                           allowViewCustomization={false}
                           showSearchInput={false}
                           showExport={false}
                />
            )}

        </div>
    )
});

export const EventListingGridPanel = withQueryModels<EventListingProps>(EventListingGridPanelImpl);