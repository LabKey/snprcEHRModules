import { SCHEMAS } from '../../schemas';
import { Actions, GridPanel, InjectedQueryModels, LoadingSpinner, withQueryModels } from '@labkey/components';
import React, { FC, useEffect, useRef } from 'react';
import { Filter } from '@labkey/api';
import { usePrevious } from './LookupSetsGridPanel';
import { Col, Row } from 'react-bootstrap';

interface LookupsProps {
    lookupSetId: string,
    actions: Actions,
    queryModels: any,
    handleStateChange?: (response: any, resetSelection: boolean) => any;
}

type Props = LookupsProps & InjectedQueryModels;

export const LookupsGridPanel: FC<LookupsProps> = React.memo(props => {
    const { actions, queryModels, lookupSetId , handleStateChange} = props;
    const prevLookupSetId = usePrevious(lookupSetId);

    useEffect(() => {
        if(prevLookupSetId !== lookupSetId) {
            initQueryModel()
        }
    }, [lookupSetId])


    const initQueryModel = () => {
        const baseFilters = [Filter.create('lookupSetId', lookupSetId)];
        actions.addModel(
            {
                id: lookupSetId,
                schemaQuery: SCHEMAS.SND_TABLES.LOOKUPS,
                baseFilters,
                omittedColumns: ['label', 'description', 'folder', 'createdby', 'created', 'modifiedby', 'modified', 'objectid'],
                bindURL: true
            },
            true,
            true
        );

    }

    return (
        <>

            {!queryModels[lookupSetId] && <LoadingSpinner />}
            {queryModels[lookupSetId] && (
                <GridPanel actions={actions}
                           model = {queryModels[lookupSetId]}
                           loadOnMount ={true}
                           title={lookupSetId}
                           highlightLastSelectedRow
                />
            )}
        </>

    )
});