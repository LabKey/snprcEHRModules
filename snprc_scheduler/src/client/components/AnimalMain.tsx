import React, { useCallback } from "react";
import { useDispatch, useSelector } from "react-redux";
import {
    setAvailableAnimalFilter,
    addTimelineAnimalItem
} from "../actions/dataActions";
import { Column, DataGrid, RenderCellProps } from "react-data-grid";
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { library } from '@fortawesome/fontawesome-svg-core';
import { faPlus } from '@fortawesome/free-solid-svg-icons';
import { Button } from "react-bootstrap";
import { Animal, Project, Timeline } from "../models/models";

library.add(faPlus);

interface RootState {
    project: {
        selectedProject: Project | null;
    };
    timeline: {
        selectedTimeline: Timeline | null;
    };
    animal: {
        availableAnimals: Animal[];
    };
}

const AnimalMain: React.FC = () => {
    const dispatch = useDispatch();
    
    const selectedProject = useSelector((state: RootState) => state.project.selectedProject || null);
    const selectedTimeline = useSelector((state: RootState) => 
        (state.project.selectedProject != null) ? state.timeline.selectedTimeline : null
    );
    const availableAnimals = useSelector((state: RootState) => state.animal.availableAnimals);

    const handleAnimalFilter = useCallback((event: React.ChangeEvent<HTMLInputElement>) => {
        dispatch(setAvailableAnimalFilter(event.target.value));
    }, [dispatch]);

    const handleAssignAnimal = useCallback((row: Animal) => {
        if (selectedTimeline) {
            dispatch(addTimelineAnimalItem({
                ...row,
                AnimalId: row.Id,
                IsDeleted: false,
                IsDirty: true
            }, selectedTimeline));
        }
    }, [dispatch, selectedTimeline]);

    const AddButtonFormatter = useCallback(({ row }: RenderCellProps<Animal>) => {
        const disableBtn = (!selectedTimeline || !selectedTimeline.savedDraft);

        return (
            <Button 
                disabled={disableBtn} 
                onClick={() => handleAssignAnimal(row)} 
                className='animal-grid-add'
            >
                <FontAwesomeIcon icon={faPlus} />
            </Button>
        );
    }, [selectedTimeline, handleAssignAnimal]);

    const getColumns = useCallback((): Column<Animal>[] => {
        return [
            {
                key: 'add',
                name: '',
                width: 45,
                renderCell: AddButtonFormatter,
                frozen: true
            },
            {
                key: 'Id',
                name: 'ID',
                sortable: true
            },
            {
                key: 'AssignmentStatus',
                name: 'IACUC Status',
                sortable: true
            },
            {
                key: 'Gender',
                name: 'Sex',
                sortable: true
            },
            {
                key: 'Weight',
                name: 'Weight',
                sortable: true
            },
            {
                key: 'Age',
                name: 'Age',
                sortable: true
            }
        ];
    }, [AddButtonFormatter]);

    const columns = getColumns();

    return (
        <>
            <div className="input-group bottom-padding-8">
                <span className="input-group-addon input-group-addon-buffer"><i
                    className="fa fa-search"></i></span>
                <input
                    id="availableAnimalSearch"
                    type="text"
                    onChange={handleAnimalFilter}
                    className="form-control search-input"
                    name="availableAnimalSearch"
                    placeholder="Search available animals"/>
            </div>
            <div className="col-sm-12 scheduler-main-table">
                <DataGrid
                    className='animal-available-table'
                    columns={columns}
                    rows={availableAnimals || []}
                    rowKeyGetter={(row) => row.Id || ''}
                    style={{ height: 'calc(67vh - 160px - 50px)' }}
                    defaultColumnOptions={{ resizable: true }}
                />
            </div>
        </>
    );
};

export default AnimalMain;
