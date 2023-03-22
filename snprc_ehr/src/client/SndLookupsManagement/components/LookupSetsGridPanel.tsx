import React, { FC, useEffect, useRef, useState } from 'react';
import {
    GridPanel,
    InjectedQueryModels, isLoading, LoadingSpinner,
    LoadingState,
    QueryModel,
    withQueryModels
} from '@labkey/components';
import { SCHEMAS } from '../../schemas';
import { LookupsGridPanel } from './LookupsGridPanel';
import { Col, Row } from 'react-bootstrap';
import '../styles/sndLookupsManagement.scss'
interface LookupSetProps {
    handleStateChange?: (response: any) => any;
}

type Props = LookupSetProps & InjectedQueryModels;

const LookupSetsGridPanelImpl: FC<Props> = React.memo(props => {
    const { actions, queryModels } = props;
    const [lookupSetId, setLookupSetId] = useState<string>('2175');

    useEffect(() => {
        setLastSelectedLookupSetId();
        initQueryModel();
    },[]);

    const initQueryModel = () => {
        actions.addModel(
            {
                id: 'lookupSets',
                schemaQuery: SCHEMAS.SND_TABLES.LOOKUP_SETS,
                omittedColumns: ['label', 'description', 'folder', 'createdby', 'created', 'modifiedby', 'modified', 'objectid'],
                bindURL: true
            },
            true,
            true
        );
        actions.setMaxRows('lookupSets', 200);
    }


    const onRowSelectionChange = (model: QueryModel, row: any, checked: boolean): void => {
        let selectedLookupSetId;
        if (checked) {
            if (row) {
                selectedLookupSetId = row.getIn(['lookupSetId', 'value']);
            } else if (model.hasSelections) {
                selectedLookupSetId = getLastSelectedLookupSetId();
            }
        }
        updateSelectedLookupSetId(selectedLookupSetId);
    }

    const setLastSelectedLookupSetId = () => {
        const model = queryModels['lookupSets'];
        if (!model || isLoading(model.selectionsLoadingState)) return;

        if (model.selectionsLoadingState === LoadingState.LOADED) {
            updateSelectedLookupSetId(getLastSelectedLookupSetId());
        }
    }

    const updateSelectedLookupSetId = (selectedLookupSetId: string) => {
        //if (lookupSetId !== selectedLookupSetId) {
        setLookupSetId(selectedLookupSetId);
        //}
    }

    const getLastSelectedLookupSetId = (): string => {
        const selectedLookupSetIds = queryModels['lookupSets'].selections;
        return selectedLookupSetIds.size > 0 ? Array.from(selectedLookupSetIds).pop() : undefined;
    }

    const reloadLookupSetsModel = () => {
        actions.loadModel('lookupSets', true);
    }

    return (
        <div>
            <Row>
                <Col xs={10} md={4} >
                    {!queryModels['lookupSets'] && <LoadingSpinner />}
                    {queryModels['lookupSets'] && (
                        <GridPanel actions={actions}
                                   model = {queryModels['lookupSets']}
                                   loadOnMount ={true}
                                   title={'Lookup Sets'}
                                   highlightLastSelectedRow
                                   showPagination={false}
                                   pageSizes={[200]}
                                   allowSelections={true}

                        />
                    )}
                </Col>
                <Col xs={10} md={7}>
                    <LookupsGridPanel lookupSetId={lookupSetId} actions={actions} queryModels={queryModels} />
                </Col>
            </Row>
        </div>
    )
})

export const usePrevious = (value) => {
    const ref = useRef();
    useEffect(() => {
        ref.current = value;
    }, [value]);
    return ref.current;
}

export const LookupSetsGridPanel = withQueryModels<{}>(LookupSetsGridPanelImpl);