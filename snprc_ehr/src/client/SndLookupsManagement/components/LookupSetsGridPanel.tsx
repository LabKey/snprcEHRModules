import React, { FC, useEffect, useRef, useState } from 'react';
import {
    GridPanel,
    InjectedQueryModels, isLoading, LoadingSpinner,
    LoadingState, ManageDropdownButton, QueryModel, SelectionMenuItem,
    withQueryModels
} from '@labkey/components';
import { SCHEMAS } from '../../schemas';
import { LookupsGridPanel } from './LookupsGridPanel';
import { Button, Col, Row } from 'react-bootstrap';
import '../styles/sndLookupsManagement.scss'
import { ManageButtons } from './ManageButtons';

const LookupSetsGridPanelImpl: FC<InjectedQueryModels> = React.memo(props => {
    const { actions, queryModels } = props;
    const [lookupSetId, setLookupSetId] = useState<string>('');
    const [showDialog, setShowDialog] = useState<string>('');

    useEffect(() => {
        setLastSelectedLookupSetId();
        initQueryModel();
    },[]);

    useEffect(() => {
        setLastSelectedLookupSetId();
    }, [queryModels['lookupSets']])

    const initQueryModel = () => {
        actions.addModel(
            {
                id: 'lookupSets',
                schemaQuery: SCHEMAS.SND_TABLES.LOOKUP_SETS,
                omittedColumns: ['label', 'description', 'Folder', 'createdby', 'created', 'modifiedby', 'modified', 'objectid'],
                bindURL: true
            },
            true,
            true
        );
        actions.setMaxRows('lookupSets', 300);
    }


    const setLastSelectedLookupSetId = () => {
        const model = queryModels['lookupSets'];
        if (!model || isLoading(model.selectionsLoadingState)) return;

        if (model.selectionsLoadingState === LoadingState.LOADED) {
            updateSelectedLookupSetId(getLastSelectedLookupSetId());
        }
    }

    const updateSelectedLookupSetId = (selectedLookupSetId: string) => {
        if (lookupSetId !== selectedLookupSetId) {
            setLookupSetId(selectedLookupSetId);
        }
    }

    const getLastSelectedLookupSetId = (): string => {
        const selectedLookupSetIds = queryModels['lookupSets'].selections;
        return selectedLookupSetIds.size > 0 ? Array.from(selectedLookupSetIds).pop() : undefined;
    }

    const toggleDialog = (name: string, requiresSelection = false): void => {
        if (requiresSelection && queryModels['lookupSets'].hasSelections) {
            setShowDialog(undefined);
        } else {
            setShowDialog(name);
        }
    }

    const closeDialog = (): void => {
        toggleDialog(undefined);
    }

    const onCreateComplete = (response: any): void => {
        closeDialog();
        onRowSelectionChange(queryModels['lookupSets'], undefined, false);
        reloadLookupSetModel();
    }

    const reloadLookupSetModel = (): void => {
        actions.loadModel('lookupSets', true);
    }

    const onRowSelectionChange = (model: QueryModel, row: any, checked: boolean): void => {
        let selectedId;

        if (checked) {
            if (row) {
                selectedId = row.getIn(['lookupSetId', 'value']);
            } else if (model.hasSelections) {
                selectedId = getLastSelectedLookupSetId();
            }
        }
        updateSelectedLookupSetId(selectedId);
    }

    const renderButtons = () => {
        const model = queryModels['lookupSets'];
        return (
            <div className="btn-group">
                {<Button bsStyle={'success'}>Create</Button>}
                <ManageDropdownButton id={`lookupSets`}>
                    <SelectionMenuItem id={"delete-menu-item"} text={"Delete"} queryModel={model} />
                    <SelectionMenuItem id={"edit-menu-item"} text={"Edit"} queryModel={model} />
                </ManageDropdownButton>
            </div>
        )
    }

    return (
        <div>
            <Row>
                <Col xs={10} md={4} className={"sidenav"} >
                    {!queryModels['lookupSets'] && <LoadingSpinner />}
                    {queryModels['lookupSets'] && (
                        <GridPanel actions={actions}
                                   model = {queryModels['lookupSets']}
                                   loadOnMount ={true}
                                   highlightLastSelectedRow
                                   showPagination={false}
                                   allowSelections={true}
                                   title={"Lookup Key"}
                                   ButtonsComponent={renderButtons}

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