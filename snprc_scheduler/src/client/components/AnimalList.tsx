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
import { BootstrapTable, TableHeaderColumn } from 'react-bootstrap-table';
import { connect } from 'react-redux';
import { Button, Glyphicon } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { library } from '@fortawesome/fontawesome-svg-core';
import { faMinus } from '@fortawesome/free-solid-svg-icons';

import { AppState } from '../reducers';
import {
    deleteTimelineAnimalItem,
    hideAlertBanner,
    hideAlertModal,
    hideConfirm,
    setAssignedAnimalFilter,
    setForceRerender,
    setTimelineClean,
    showAlertBanner,
    showAlertModal,
    showConfirm,
    updateTimelineAnimalItem,
} from '../actions/dataActions';

library.add(faMinus);

class AnimalList extends React.Component<any, any> {
    
    constructor(props) {
        super(props);

        this.state = {
            animals: [], 
            animalCols: [
                { key: 'Id', name: 'ID', width: 70 },
                { key: 'Gender', name: 'Gender', width: 82 },
                { key: 'Weight', name: 'Weight', width: 90 },
                { key: 'Age', name: 'Age', width: 130 },
            ],
            selectedAnimals: [],
        };
    }

    options = {
        noDataText: 'No animals assigned',
    };

    componentDidMount(): void {
        const { forceRerender, setForceRerender } = this.props;
        if (forceRerender) {
            setForceRerender(false);
        }
    }
    
    componentDidUpdate(): void {
        const { forceRerender, setForceRerender } = this.props;
        if (forceRerender) {
            setForceRerender(false);
        }
    }

    handleAnimalFilter = (event): void => {
        this.props.setAssignedAnimalFilter(event.target.value);
    };

    handleUnassignAnimal = (id) => {
        const { deleteTimelineAnimalItem, selectedTimeline } = this.props;

        return (() => {
            deleteTimelineAnimalItem(id, selectedTimeline);
        });
    };

    getCellEditProps = () => {
        return ((() => {
            let me = this;
            return {
                mode: 'dbclick',
                blurToSave: true,
                nonEditableRows: function () {


                },
                afterSaveCell: function(row, cellName, cellValue) {
                    me.props.updateTimelineAnimalItem({...row,
                                                    AnimalId: row.Id,
                                                    EndDate: cellValue,
                                                    IsDeleted: false,
                                                    IsDirty: true}, me.props.selectedTimeline);
                }
            }
        }).apply(this));
    };

    addFormatter = (cell, row) => {
        const { selectedTimeline } = this.props;

        return (
            <Button
                className="animal-grid-add"
                disabled={!selectedTimeline || !selectedTimeline.savedDraft}
                onClick={this.handleUnassignAnimal(cell)}
            >
                <FontAwesomeIcon icon="minus" />
            </Button>
        );
    };

    render = () => {
        const { assignedAnimals } = this.props;

        return (
            <div>
                <div className="input-group top-bottom-padding-8">
                    <span className="input-group-addon input-group-addon-buffer"><Glyphicon glyph="search"/></span>
                    <input
                        id="assignedAnimalSearch"
                        type="text"
                        onChange={this.handleAnimalFilter}
                        className="form-control search-input"
                        name="assignedAnimalSearch"
                        placeholder="Search assigned animals"
                    />
                </div>
                <div>
                    <BootstrapTable
                        ref="assigned-animal-table"
                        className="animal-table"
                        data={assignedAnimals}
                        options={this.options}
                        cellEdit={this.getCellEditProps()}
                        height={240}
                    >
                        <TableHeaderColumn dataField="Id" width="45px" sortFunc={() => {
                        }} dataFormat={this.addFormatter} dataSort />
                        <TableHeaderColumn dataField="Id" width="60px" isKey dataSort editable={false}>
                            ID
                        </TableHeaderColumn>
                        <TableHeaderColumn dataField="Gender" width="60px" dataSort editable={false}>
                            Sex
                        </TableHeaderColumn>
                        <TableHeaderColumn dataField="Weight" width="78px" dataSort editable={false}>
                            Weight
                        </TableHeaderColumn>
                        <TableHeaderColumn dataField="Age" width="85px" dataSort editable={false}>
                            Age
                        </TableHeaderColumn>
                        <TableHeaderColumn dataField="EndDate" editable={{ type: 'date' }} dataSort>
                            End Date
                        </TableHeaderColumn>
                    </BootstrapTable>
                </div>
            </div>
        )
    }
}

const mapStateToProps = (state: AppState) => ({
    selectedProject: state.project.selectedProject || null,
    selectedTimeline: (state.project.selectedProject != null) ? state.timeline.selectedTimeline : null,
    assignedAnimals: state.animal.assignedAnimals,
    forceRerender: state.root.forceRerender  // Bit of a hack to get a re-render
});

const mapDispatchToProps = dispatch => ({
    showConfirm: confirm => dispatch(showConfirm(confirm)),
    hideConfirm: () => dispatch(hideConfirm()),
    showAlert: alert => dispatch(showAlertModal(alert)),
    hideAlert: () => dispatch(hideAlertModal()),
    hideAlertBanner: timeline => dispatch(hideAlertBanner(timeline)),
    showAlertBanner: timeline => dispatch(showAlertBanner(timeline)),
    cleanTimeline: timeline => dispatch(setTimelineClean(timeline)),
    setForceRerender: render => dispatch(setForceRerender(render)),
    deleteTimelineAnimalItem: (id, timeline) => dispatch(deleteTimelineAnimalItem(id, timeline)),
    setAssignedAnimalFilter: item => dispatch(setAssignedAnimalFilter(item)),
    updateTimelineAnimalItem: (item, timeline) => dispatch(updateTimelineAnimalItem(item, timeline))
});

export default connect(mapStateToProps, mapDispatchToProps)(AnimalList);
