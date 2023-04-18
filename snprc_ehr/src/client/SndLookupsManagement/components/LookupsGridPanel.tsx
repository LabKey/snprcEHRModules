import { SCHEMAS } from '../../schemas';
import { Actions, GridPanel} from '@labkey/components';
import React, { FC, useEffect } from 'react';
import { Filter } from '@labkey/api';
import { usePrevious } from './LookupSetsGridPanel';
import { ManageButtons } from './ManageButtons';

interface LookupsProps {
    lookupSetId: string,
    actions: Actions,
    queryModels: any
}

export const LookupsGridPanel: FC<LookupsProps> = React.memo(props => {
    const { actions, queryModels, lookupSetId } = props;
    const prevLookupSetId = usePrevious(lookupSetId);

    useEffect(() => {
        initQueryModel();
    }, []);

    useEffect(() => {
        if(prevLookupSetId !== lookupSetId) {
            initQueryModel();
        } else {
            actions.loadModel(lookupSetId);
        }
    }, [lookupSetId])


    const initQueryModel = () => {
        const baseFilters = [Filter.create('lookupSetId', lookupSetId)];
        actions.addModel(
            {
                id: lookupSetId,
                schemaQuery: SCHEMAS.SND_TABLES.LOOKUPS,
                baseFilters,
                omittedColumns: ['label', 'description', 'folder', 'createdby', 'created', 'modifiedby', 'modified', 'objectid', 'sortOrder'],
                bindURL: true
            },
            true,
            true
        );

    }

    return (
        <>
            {queryModels[lookupSetId] && (
                <GridPanel actions={actions}
                           model = {queryModels[lookupSetId]}
                           loadOnMount ={true}
                           highlightLastSelectedRow={true}
                           showPagination={false}
                           title={"Value"}
                           ButtonsComponent={ManageButtons}
                />
            )}
        </>

    )
});