import React from 'react';
import { connect } from 'react-redux';
import { Button, Glyphicon } from 'react-bootstrap';
import { BootstrapTable, TableHeaderColumn } from 'react-bootstrap-table';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { library } from '@fortawesome/fontawesome-svg-core';
import { faPlus } from '@fortawesome/free-solid-svg-icons';

import { AppState } from '../reducers';
import { addTimelineAnimalItem, setAvailableAnimalFilter } from '../actions/dataActions';

library.add(faPlus);

const tableOptions = {
    noDataText: 'No unassigned animals available',
};

interface DispatchProps {
    addTimelineAnimalItem: (item, timeline) => void;
    setAvailableAnimalFilter: (filter: any) => void;
}

interface StateProps {
    availableAnimals: any;
    selectedProject: any;
    selectedTimeline: any;
}

type Props = DispatchProps & StateProps;

class AnimalMain extends React.Component<Props> {

    handleAnimalFilter = (event): void => {
        this.props.setAvailableAnimalFilter(event.target.value);
    };

    handleAssignAnimal = (cell, row) => {
        const { addTimelineAnimalItem, selectedTimeline } = this.props;

        return (() => {
            const item = {
                ...row,
                AnimalId: row.Id,
                IsDeleted: false,
                IsDirty: true,
            };

            addTimelineAnimalItem(item, selectedTimeline);
        });
    };

    addFormatter = (cell, row) => {
        const { selectedTimeline } = this.props;
        const disableBtn = (!selectedTimeline || !selectedTimeline.savedDraft);

        return (
            <Button disabled={disableBtn} onClick={this.handleAssignAnimal(cell, row)} className="animal-grid-add">
                <FontAwesomeIcon icon="plus" />
            </Button>
        );
    };

    render() {
        const { availableAnimals } = this.props;

        return (
            <>
                <div className="input-group bottom-padding-8">
                    <span className="input-group-addon input-group-addon-buffer"><Glyphicon glyph="search" /></span>
                    <input
                        id="availableAnimalSearch"
                        type="text"
                        onChange={this.handleAnimalFilter}
                        className="form-control search-input"
                        name="availableAnimalSearch"
                        placeholder="Search available animals"
                    />
                </div>
                <div className="col-sm-12 scheduler-main-table">
                    <BootstrapTable
                        ref="animal-available-table"
                        className="animal-available-table"
                        data={availableAnimals}
                        options={tableOptions}
                        striped
                        height={438}
                    >
                        <TableHeaderColumn
                            dataField="Id"
                            width="45px"
                            sortFunc={() => {}}
                            dataFormat={this.addFormatter}
                            dataSort
                        />
                        <TableHeaderColumn dataField="Id" isKey dataSort>ID</TableHeaderColumn>
                        <TableHeaderColumn dataField="AssignmentStatus" dataSort>IACUC Status</TableHeaderColumn>
                        <TableHeaderColumn dataField="Gender" dataSort>Sex</TableHeaderColumn>
                        <TableHeaderColumn dataField="Weight" dataSort>Weight</TableHeaderColumn>
                        <TableHeaderColumn dataField="Age" dataSort>Age</TableHeaderColumn>
                    </BootstrapTable>
                </div>
            </>
        );
    }
}

const mapStateToProps = (state: AppState): StateProps => ({
    availableAnimals: state.animal.availableAnimals,
    selectedProject: state.project.selectedProject || null,
    selectedTimeline: (state.project.selectedProject != null) ? state.timeline.selectedTimeline : null,
})

const mapDispatchToProps = (dispatch): DispatchProps => ({
    addTimelineAnimalItem: (item, timeline) => dispatch(addTimelineAnimalItem(item, timeline)),
    setAvailableAnimalFilter: filter => dispatch(setAvailableAnimalFilter(filter)),
})

export default connect<StateProps, DispatchProps, any>(mapStateToProps, mapDispatchToProps)(AnimalMain);
