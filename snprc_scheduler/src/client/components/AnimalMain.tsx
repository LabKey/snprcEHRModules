import React, { ChangeEvent, FC, useCallback } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { addTimelineAnimalItem, setAvailableAnimalFilter } from '../actions/dataActions';
import { Column, DataGrid, RenderCellProps } from 'react-data-grid';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { library } from '@fortawesome/fontawesome-svg-core';
import { faPlus } from '@fortawesome/free-solid-svg-icons';
import { Button, OverlayTrigger, Tooltip } from 'react-bootstrap';
import { Animal, Project, Timeline } from '../models/models';

library.add(faPlus);

interface RootState {
    animal: {
        availableAnimals: Animal[];
    };
    project: {
        selectedProject: null | Project;
    };
    timeline: {
        selectedTimeline: null | Timeline;
    };
}

const AnimalMain: FC = () => {
    const dispatch = useDispatch();

    const selectedProject = useSelector((state: RootState) => state.project.selectedProject || null);
    const selectedTimeline = useSelector((state: RootState) =>
        state.project.selectedProject != null ? state.timeline.selectedTimeline : null
    );
    const availableAnimals = useSelector((state: RootState) => state.animal.availableAnimals);

    const handleAnimalFilter = useCallback(
        (event: ChangeEvent<HTMLInputElement>) => {
            dispatch(setAvailableAnimalFilter(event.target.value));
        },
        [dispatch]
    );

    const handleAssignAnimal = useCallback(
        (row: Animal) => {
            if (selectedTimeline) {
                dispatch(
                    addTimelineAnimalItem(
                        {
                            ...row,
                            AnimalId: row.Id,
                            IsDeleted: false,
                            IsDirty: true,
                        },
                        selectedTimeline
                    )
                );
            }
        },
        [dispatch, selectedTimeline]
    );

    const AddButtonFormatter = useCallback(
        ({ row }: RenderCellProps<Animal>) => {
            const disableBtn = !selectedTimeline || !selectedTimeline.savedDraft;
            const button = (
                <Button className="animal-grid-add" disabled={disableBtn} onClick={() => handleAssignAnimal(row)}>
                    <FontAwesomeIcon icon={faPlus} />
                </Button>
            );

            if (disableBtn) {
                const tooltip = <Tooltip id="add-animal-tooltip">Timeline must be saved as a draft before animals assignments can be changed.</Tooltip>;
                return (
                    <OverlayTrigger overlay={tooltip} placement="top">
                        <span className="d-inline-block animal-grid-add-disabled-wrapper">{button}</span>
                    </OverlayTrigger>
                );
            }

            return button;
        },
        [selectedTimeline, handleAssignAnimal]
    );

    const getColumns = useCallback((): Column<Animal>[] => {
        return [
            {
                key: 'add',
                name: '',
                width: 45,
                renderCell: AddButtonFormatter,
                frozen: true,
            },
            {
                key: 'Id',
                name: 'ID',
                sortable: true,
            },
            {
                key: 'AssignmentStatus',
                name: 'IACUC Status',
                sortable: true,
            },
            {
                key: 'Gender',
                name: 'Sex',
                sortable: true,
            },
            {
                key: 'Weight',
                name: 'Weight',
                sortable: true,
            },
            {
                key: 'Age',
                name: 'Age',
                sortable: true,
            },
        ];
    }, [AddButtonFormatter]);

    const columns = getColumns();
    const hasAnimals = availableAnimals && availableAnimals.length > 0;

    return (
        <>
            <div className="input-group bottom-padding-8">
                <span className="input-group-addon input-group-addon-buffer">
                    <i className="fa fa-search"></i>
                </span>
                <input
                    className="form-control search-input"
                    id="availableAnimalSearch"
                    name="availableAnimalSearch"
                    onChange={handleAnimalFilter}
                    placeholder="Search available animals"
                    type="text"
                />
            </div>
            <div className="col-sm-12 scheduler-main-table datagrid-container-relative">
                <DataGrid
                    className="animal-available-table"
                    columns={columns}
                    defaultColumnOptions={{ resizable: true }}
                    rowKeyGetter={row => row.Id || ''}
                    rows={availableAnimals || []}
                    style={{ height: 'calc(67vh - 160px - 50px)' }}
                />
                {!hasAnimals && <div className="datagrid-empty-message">No unassigned animals available</div>}
            </div>
        </>
    );
};

export default AnimalMain;
