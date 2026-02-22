import React, { ChangeEvent, FC, useCallback, useEffect, useMemo } from 'react';
import {
    deleteTimelineAnimalItem,
    setAssignedAnimalFilter,
    setForceRerender,
    updateTimelineAnimalItem,
} from '../actions/dataActions';
import { Column, DataGrid } from 'react-data-grid';
import { connect } from 'react-redux';
import { Button, OverlayTrigger, Tooltip } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { library } from '@fortawesome/fontawesome-svg-core';
import { faMinus } from '@fortawesome/free-solid-svg-icons';
import { Animal, Project, Timeline } from '../models/models';
import { Dispatch } from 'redux';

library.add(faMinus);

interface AnimalListProps {
    assignedAnimals: Animal[];
    deleteTimelineAnimalItem: (id: string, timeline: null | Timeline) => void;
    forceRerender: boolean;
    selectedProject: null | Project;
    selectedTimeline: null | Timeline;
    setAssignedAnimalFilter: (filter: string) => void;
    setForceRerender: (render: boolean) => void;
    updateTimelineAnimalItem: (item: Animal, timeline: null | Timeline) => void;
}

const AnimalList: FC<AnimalListProps> = props => {
    const {
        selectedTimeline,
        assignedAnimals,
        forceRerender,
        setForceRerender,
        setAssignedAnimalFilter,
        deleteTimelineAnimalItem,
        updateTimelineAnimalItem,
    } = props;

    useEffect(() => {
        if (forceRerender) {
            setForceRerender(false);
        }
    }, [forceRerender, setForceRerender]);

    const handleAnimalFilter = (event: ChangeEvent<HTMLInputElement>) => {
        setAssignedAnimalFilter(event.target.value);
    };

    const handleUnassignAnimal = useCallback(
        (id: string) => {
            deleteTimelineAnimalItem(id, selectedTimeline);
        },
        [deleteTimelineAnimalItem, selectedTimeline]
    );

    const UnassignButtonFormatter = useCallback(
        ({ row }: { row: Animal }) => {
            const disableBtn = !selectedTimeline || !selectedTimeline.savedDraft;
            const button = (
                <Button className="animal-grid-add" style={{ borderColor: 'darkgray' }} disabled={disableBtn} onClick={() => handleUnassignAnimal(row.Id!)}>
                    <FontAwesomeIcon icon={faMinus} />
                </Button>
            );

            if (disableBtn) {
                const tooltip = <Tooltip id="unassign-animal-tooltip">Timeline must be saved as a draft before animals assignments can be changed.</Tooltip>;
                return (
                    <OverlayTrigger overlay={tooltip} placement="top">
                        <span className="d-inline-block animal-grid-add-disabled-wrapper">{button}</span>
                    </OverlayTrigger>
                );
            }

            return button;
        },
        [selectedTimeline, handleUnassignAnimal]
    );

    const onRowsChange = useCallback(
        (rows: Animal[], data: any) => {
            const { column, indexes } = data;

            if (column.key === 'EndDate') {
                const rowIndex = indexes[0];
                const updatedRow = rows[rowIndex];

                updateTimelineAnimalItem(
                    {
                        ...updatedRow,
                        AnimalId: updatedRow.Id,
                        EndDate: updatedRow.EndDate,
                        IsDeleted: false,
                        IsDirty: true,
                    },
                    selectedTimeline
                );
            }
        },
        [updateTimelineAnimalItem, selectedTimeline]
    );

    const columns = useMemo((): Column<Animal>[] => {
        return [
            {
                key: 'unassign',
                name: '',
                width: 45,
                renderCell: UnassignButtonFormatter,
                frozen: true,
            },
            {
                key: 'Id',
                name: 'ID',
                width: 60,
                sortable: true,
            },
            {
                key: 'status',
                name: 'Status',
                width: 80,
                sortable: true,
            },
            {
                key: 'Gender',
                name: 'Sex',
                width: 60,
                sortable: true,
            },
            {
                key: 'Weight',
                name: 'Weight',
                width: 78,
                sortable: true,
            },
            {
                key: 'Age',
                name: 'Age',
                width: 85,
                sortable: true,
            },
            {
                key: 'EndDate',
                name: 'End Date',
                sortable: true,
                editable: true,
            },
        ];
    }, [UnassignButtonFormatter]);

    const hasAnimals = assignedAnimals && assignedAnimals.length > 0;

    const search = (
        <div className="input-group top-bottom-padding-8">
            <span className="input-group-addon input-group-addon-buffer">
                <i className="fa fa-search"></i>
            </span>
            <input
                className="form-control search-input"
                id="assignedAnimalSearch"
                name="assignedAnimalSearch"
                onChange={handleAnimalFilter}
                placeholder="Search assigned animals"
                type="text"
            />
        </div>
    );

    return (
        <div>
            {search}
            <div className="datagrid-container-relative">
                <DataGrid
                    className="animal-table"
                    columns={columns}
                    defaultColumnOptions={{ resizable: true }}
                    onRowsChange={onRowsChange}
                    rowKeyGetter={(row: Animal) => row.Id!}
                    rows={assignedAnimals || []}
                    style={{ height: 'calc(50vh - 160px - 50px)' }}
                />
                {!hasAnimals && <div className="datagrid-empty-message">No animals assigned</div>}
            </div>
        </div>
    );
};

const mapStateToProps = (state: any) => ({
    selectedProject: state.project.selectedProject || null,
    selectedTimeline: state.project.selectedProject != null ? state.timeline.selectedTimeline : null,
    assignedAnimals: state.animal.assignedAnimals,
    forceRerender: state.root.forceRerender, // Bit of a hack to get a re-render
});

const mapDispatchToProps = (dispatch: Dispatch<any>) => ({
    setForceRerender: (render: boolean) => dispatch(setForceRerender(render)),
    deleteTimelineAnimalItem: (id: string, timeline: Timeline) => dispatch(deleteTimelineAnimalItem(id, timeline)),
    setAssignedAnimalFilter: (item: string) => dispatch(setAssignedAnimalFilter(item)),
    updateTimelineAnimalItem: (item: Animal, timeline: Timeline) => dispatch(updateTimelineAnimalItem(item, timeline)),
});

export default connect(mapStateToProps, mapDispatchToProps)(AnimalList);
