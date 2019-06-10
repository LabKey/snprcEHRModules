import React from "react";
import connect from "react-redux/es/connect/connect";
import {
    addTimelineAnimalItem,
    hideAlertBanner,
    hideAlertModal,
    hideConfirm, setAvailableAnimalFilter, setTimelineClean,
    showAlertBanner,
    showAlertModal,
    showConfirm
} from "../actions/dataActions";
import {BootstrapTable, TableHeaderColumn} from "react-bootstrap-table";
import Glyphicon from 'react-bootstrap/lib/Glyphicon'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { library } from '@fortawesome/fontawesome-svg-core';
import { faPlus} from '@fortawesome/free-solid-svg-icons';
import {Button} from "react-bootstrap";

library.add(faPlus);

const tableOptions = {
    noDataText: 'No animals available'
};

class AnimalMain extends React.Component {

    handleAnimalFilter = (event) => {
        this.props.setAvailableAnimalFilter(event.target.value)
    };

    handleAssignAnimal = (cell, row) => {
        const { addTimelineAnimalItem, selectedTimeline} = this.props;

        return (() => {
            addTimelineAnimalItem({...row,
                AnimalId: row.Id,
                IsDeleted: false,
                IsDirty: true}, selectedTimeline);
        });
    };

    addFormatter = (cell, row) => {
        const { selectedTimeline } = this.props;
        const disableBtn = (!selectedTimeline || !selectedTimeline.savedDraft);

        return (<Button disabled={disableBtn} onClick={this.handleAssignAnimal(cell, row)} className='animal-grid-add'><FontAwesomeIcon icon={["fa", "plus"]} /></Button>)
    };

    render() {
        const {availableAnimals} = this.props;

        return (
                <>
                    <div className="input-group bottom-padding-8">
                        <span className="input-group-addon input-group-addon-buffer"><Glyphicon glyph="search"/></span>
                        <input
                                id="availableAnimalSearch"
                                type="text"
                                onChange={this.handleAnimalFilter}
                                className="form-control search-input"
                                name="availableAnimalSearch"
                                placeholder="Search available animals"/>
                    </div>
                    <div className="col-sm-12 scheduler-main-table">
                        <BootstrapTable
                                ref='animal-available-table'
                                className='animal-available-table'
                                data={availableAnimals}
                                options={tableOptions}
                                striped
                                height={438}
                        >
                            <TableHeaderColumn dataField='Id' width='45px' sortFunc={() => {
                            }} dataFormat={this.addFormatter} dataSort={true}/>
                            <TableHeaderColumn dataField='Id' isKey={true} dataSort={true}>ID</TableHeaderColumn>
                            <TableHeaderColumn dataField='AssignmentStatus' dataSort={true}>IACUC Status</TableHeaderColumn>
                            <TableHeaderColumn dataField='Gender' dataSort={true}>Sex</TableHeaderColumn>
                            <TableHeaderColumn dataField='Weight' dataSort={true}>Weight</TableHeaderColumn>
                            <TableHeaderColumn dataField='Age' dataSort={true}>Age</TableHeaderColumn>
                        </BootstrapTable>
                    </div>
                </>)
    }

}

const mapStateToProps = state => ({
    selectedProject: state.project.selectedProject || null,
    selectedTimeline: (state.project.selectedProject != null) ? state.timeline.selectedTimeline : null,
    availableAnimals: state.animal.availableAnimals
})

const mapDispatchToProps = dispatch => ({
    showConfirm: confirm => dispatch(showConfirm(confirm)),
    hideConfirm: confirm => dispatch(hideConfirm(confirm)),
    showAlert: alert => dispatch(showAlertModal(alert)),
    hideAlert: alert => dispatch(hideAlertModal(alert)),
    hideAlertBanner: timeline => dispatch(hideAlertBanner(timeline)),
    showAlertBanner: timeline => dispatch(showAlertBanner(timeline)),
    cleanTimeline: timeline => dispatch(setTimelineClean(timeline)),
    setAvailableAnimalFilter: filter => dispatch(setAvailableAnimalFilter(filter)),
    addTimelineAnimalItem: (item, timeline) => dispatch(addTimelineAnimalItem(item, timeline))
})

export default connect(
        mapStateToProps,
        mapDispatchToProps
)(AnimalMain)