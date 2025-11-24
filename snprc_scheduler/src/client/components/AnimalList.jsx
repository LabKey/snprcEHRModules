/* 
    ==================================================================================
    author:             David P. Smith
    email:              dsmith@txbiomed.org
    name:               snprc_scheduler
    description:        Animal procedure scheduling system     
    copyright:          Texas Biomedical Research Institute
    created:            October 4 2018      
    ==================================================================================
*/
import React from 'react';
import {
    deleteTimelineAnimalItem,
    setAssignedAnimalFilter,
    setForceRerender,
    updateTimelineAnimalItem
} from '../actions/dataActions';
import { DataGrid } from 'react-data-grid';
import { connect } from "react-redux";
import { Button } from "react-bootstrap";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { library } from '@fortawesome/fontawesome-svg-core';
import { faMinus } from '@fortawesome/free-solid-svg-icons';

library.add(faMinus);

class AnimalList extends React.Component {
    
    constructor(props) {
        super(props);
        this.state = {};
    }

    handleAnimalFilter = (event) => {
        this.props.setAssignedAnimalFilter(event.target.value)
    };

    handleUnassignAnimal = (id) => {
        const { deleteTimelineAnimalItem, selectedTimeline} = this.props;
        deleteTimelineAnimalItem(id, selectedTimeline);
    };

    UnassignButtonFormatter = ({ row }) => {
        const {selectedTimeline} = this.props;
        const disableBtn = (!selectedTimeline || !selectedTimeline.savedDraft);

        return (
            <Button
                disabled={disableBtn}
                onClick={() => this.handleUnassignAnimal(row.Id)}
                className='animal-grid-add'
            >
                <FontAwesomeIcon icon={faMinus}/>
            </Button>
        );
    };

    getColumns = () => {
        const { selectedTimeline } = this.props;

        return [
            {
                key: 'unassign',
                name: '',
                width: 45,
                renderCell: this.UnassignButtonFormatter,
                frozen: true
            },
            {
                key: 'Id',
                name: 'ID',
                width: 60,
                sortable: true
            },
            {
                key: 'Gender',
                name: 'Sex',
                width: 60,
                sortable: true
            },
            {
                key: 'Weight',
                name: 'Weight',
                width: 78,
                sortable: true
            },
            {
                key: 'Age',
                name: 'Age',
                width: 85,
                sortable: true
            },
            {
                key: 'EndDate',
                name: 'End Date',
                sortable: true,
                editable: true
            }
        ];
    };

    onRowsChange = (rows, data) => {
        const { column, indexes } = data;

        if (column.key === 'EndDate') {
            const rowIndex = indexes[0];
            const updatedRow = rows[rowIndex];

            this.props.updateTimelineAnimalItem({
                ...updatedRow,
                AnimalId: updatedRow.Id,
                EndDate: updatedRow.EndDate,
                IsDeleted: false,
                IsDirty: true
            }, this.props.selectedTimeline);
        }
    };

    componentDidUpdate() {
        const { forceRerender, setForceRerender } = this.props;
        if( forceRerender ) {
            setForceRerender(false);
        }
    }

    componentDidMount() {
        const { forceRerender, setForceRerender } = this.props;
        if( forceRerender ) {
            setForceRerender(false);
        }
    }

    render = () => {
        const {assignedAnimals} = this.props;
        const columns = this.getColumns();
        const hasAnimals = assignedAnimals && assignedAnimals.length > 0;

        let searchJSX = (
                <div className="input-group top-bottom-padding-8">
                    <span className="input-group-addon input-group-addon-buffer"><i className="fa fa-search"></i></span>
                    <input
                            id="assignedAnimalSearch"
                            type="text"
                            onChange={this.handleAnimalFilter}
                            className="form-control search-input"
                            name="assignedAnimalSearch"
                            placeholder="Search assigned animals"/>
                </div>
        );
        return (
                <div>
                    {searchJSX}
                    <div className='datagrid-container-relative'>
                        <DataGrid
                                className='animal-table'
                                columns={columns}
                                rows={assignedAnimals || []}
                                rowKeyGetter={(row) => row.Id}
                                onRowsChange={this.onRowsChange}
                                style={{ height: 'calc(50vh - 160px - 50px)' }}
                                defaultColumnOptions={{ resizable: true }}
                        />
                        {!hasAnimals && (
                            <div className='datagrid-empty-message'>
                                No animals assigned
                            </div>
                        )}
                    </div>
                </div>
        )
    }
}

const mapStateToProps = state => ({
    selectedProject: state.project.selectedProject || null,
    selectedTimeline: (state.project.selectedProject != null) ? state.timeline.selectedTimeline : null,
    assignedAnimals: state.animal.assignedAnimals,
    forceRerender: state.root.forceRerender  // Bit of a hack to get a re-render
});

const mapDispatchToProps = dispatch => ({
    setForceRerender: render => dispatch(setForceRerender(render)),
    deleteTimelineAnimalItem: (id, timeline) => dispatch(deleteTimelineAnimalItem(id, timeline)),
    setAssignedAnimalFilter: (item, timeline) => dispatch(setAssignedAnimalFilter(item, timeline)),
    updateTimelineAnimalItem: (item, timeline) => dispatch(updateTimelineAnimalItem(item, timeline))
});

export default connect(
        mapStateToProps,
        mapDispatchToProps
)(AnimalList)