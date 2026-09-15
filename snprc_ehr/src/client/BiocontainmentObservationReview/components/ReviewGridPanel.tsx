import React, { FC, memo, useEffect, useMemo } from 'react';
import { Filter } from '@labkey/api';
import { GridPanel, InjectedQueryModels, QueryConfigMap, RequiresModelAndActions, withQueryModels } from '@labkey/components';
import { Button } from 'react-bootstrap';
import { REVIEW_REQUIRED } from '../constants/fields';
import { OBSERVATION_REVIEW } from '../schemas';

const MODEL_ID = 'observationReview';

export interface Reload {
    key: number;
    clearSelections: boolean;
}

interface Props {
    reload: Reload;
    onApprove: (lsid: string) => void;
    onFocus: (lsid: string) => void;
}

interface ButtonProps {
    onApprove: (lsid: string) => void;
}

// Approval is one observation at a time; bulk approval is off
const ApproveButton: FC<ButtonProps & RequiresModelAndActions> = ({ model, onApprove }) => {
    const lsid = model.selections?.size === 1 ? Array.from(model.selections)[0] : undefined;
    return (
        <div className="manage-buttons">
            <Button bsStyle="success" disabled={!lsid} onClick={() => onApprove(lsid)}>
                Approve observation
            </Button>
        </div>
    );
};

const ReviewGridPanelImpl: FC<Props & InjectedQueryModels> = memo(({ actions, queryModels, reload, onApprove, onFocus }) => {
    const model = queryModels[MODEL_ID];

    // Approved rows leave the queue, so their selections must go too; a correction keeps the row and the detail pane open.
    // Loading selections in parallel with the clear can restore the approved row's selection, so skip it when clearing.
    useEffect(() => {
        if (!reload.key) return;
        if (reload.clearSelections) actions.clearSelections(MODEL_ID);
        actions.loadModel(MODEL_ID, !reload.clearSelections, true);
    }, [reload]);

    // Single selection, as in SndLookupsManagement's TableGridPanel: ticking a second row replaces the first.
    // The detail pane follows the one selected row.
    useEffect(() => {
        const selected = model.selections ? Array.from(model.selections) : [];
        if (selected.length > 1) {
            actions.replaceSelections(MODEL_ID, [selected[selected.length - 1]]);
            return;
        }
        onFocus(selected[0]);
    }, [model.selections]);

    return (
        <GridPanel
            actions={actions}
            model={model}
            title="Observations Awaiting Review"
            loadOnMount
            highlightLastSelectedRow
            showPagination={false}
            allowSelections
            allowFiltering
            allowSorting
            showExport={false}
            showViewMenu={false}
            showChartMenu={false}
            emptyText="No observations are waiting for review."
            ButtonsComponent={ApproveButton}
            buttonsComponentProps={{ onApprove }}
        />
    );
});

const ReviewGridPanelWithQueryModels = withQueryModels<Props>(ReviewGridPanelImpl);

export const ReviewGridPanel: FC<Props> = memo(props => {
    const queryConfigs = useMemo<QueryConfigMap>(
        () => ({
            [MODEL_ID]: {
                id: MODEL_ID,
                schemaQuery: OBSERVATION_REVIEW,
                baseFilters: [Filter.create('QCState/Label', REVIEW_REQUIRED)],
                // Without this the total count is never requested, and the selection status spins forever
                includeTotalCount: true,
                maxRows: 300,
            },
        }),
        []
    );

    return <ReviewGridPanelWithQueryModels autoLoad queryConfigs={queryConfigs} {...props} />;
});