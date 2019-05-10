/* 
    ==================================================================================
    author:             David P. Smith
    email:              dsmith@txbiomed.org
    name:               snprc_scheduler
    description:        Animal procedure scheduling system     
    copyright:          Texas Biomedical Research Institute
    created:            October 15 2018      
    ==================================================================================
*/
import React from 'react';
import ReactDataGrid from 'react-data-grid';
import {BootstrapTable, TableHeaderColumn} from 'react-bootstrap-table';
import {
    selectTimeline,
    duplicateTimeline,
    selectProject,
    newTimeline,
    updateSelectedTimeline
} from '../actions/dataActions';
import PropTypes from "prop-types";
import connect from "react-redux/es/connect/connect";
import {Button, OverlayTrigger, Tooltip} from "react-bootstrap";

import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { library } from '@fortawesome/fontawesome-svg-core'
import { faCopy, faClone, faCaretDown, faCaretRight } from '@fortawesome/free-solid-svg-icons';

library.add(faCopy);
library.add(faClone);
library.add(faCaretDown);
library.add(faCaretRight);

const verboseOutput = false;

class TimelineList extends React.Component {
    
    constructor(props) {
        super(props);
        this.state = {
            debugUI: false,
            timelineCols: [
                { key: 'Description', name: 'Description', editable: true, width: 400 }
            ],
            selectedTimelines: [],
            selectedTimeline: (this.props.selectedTimeline || null),
            revTableCount: 0
        };
    }

    timelineRowGetter = (index) =>  {
        if (index > -1)
         return this.props.timelines[index];
    }

    getTooltip = (label) => {
        return (<Tooltip id="tooltip">
            {label}
        </Tooltip>)
    }

    onTimelineRowsSelected = (row, isSelected) => {

        return ((() => {
            if (!isSelected) {
                row = {};
            }
            if (this.props.selectedTimeline && this.props.selectedTimeline.RowId) {
                if (this.props.selectedTimeline.IsDirty) {
                    let conf = confirm("Opening another timeline will lose unsaved data for the current timeline. Open timeline?");
                    if (conf) {
                        this.deselectAllTimelines();
                    }
                } else {
                    this.deselectAllTimelines();
                }
            }

            this.setState({
                selectedTimeline: row
            });
            if (row != null) {
                this.props.onSelectTimeline(row);
            }
            if (verboseOutput) {
                console.log(row);
            }
        }).apply(this))
    }

    onTimelineRowsDeselected = (rows) => {
        let rowIndexes = rows.map(r => r.rowIdx);
        this.setState({ selectedTimelines: this.state.selectedTimelines.filter(i => rowIndexes.indexOf(i) === -1) });
    }

    newTimeline = () => {
        return ((() => {

            let confirmed = true;
            if (this.props.selectedTimeline && this.props.selectedTimeline.IsDirty) {
                confirmed = confirm("Creating a new timeline will lose unsaved data for the current timeline. Create timeline?")
            }

            if (confirmed) {
                let newTimeline = {
                    RowId: Math.floor(Math.random() * 10000),
                    ProjectId: this.props.selectedProject.projectId,
                    ProjectObjectId: this.props.selectedProject.ProjectObjectId,
                };

                this.props.onNewTimeline(newTimeline, this.props.selectedProject);

                this.setExpandedTimelineId(newTimeline.RowId);

                let timelineTable = this.refs["timeline-table"];

                // Look at expanded subtable
                if (timelineTable != null) {
                    for (const revTableRef in timelineTable.body.refs) {
                        if (timelineTable.body.refs.hasOwnProperty(revTableRef)) {
                            let timelineId = revTableRef.split('-')[2];

                            // Only look at selections in expanded subtable
                            if (newTimeline.RowId === parseInt(timelineId)) {
                                let revTable = timelineTable.body.refs[revTableRef];
                                revTable.setState({
                                    selectedRowKeys: [0]
                                });
                            }
                        }
                    }
                }
            }
        }).apply(this))
    }

    expandComponent = (row) => {

        return ((() => {

            let revs = [];

            for (const timeline of this.props.timelines) {
                if (timeline.RowId && timeline.RowId === row.RowId) {
                    revs.push(timeline);
                }
            }
            this.state.revTableCount++;

            const expanded = this.getExpandedTimelineIds();
            if (row.RowId === expanded[0] && this.props.selectedTimeline.RowId !== revs[0].RowId)
                this.props.onSelectTimeline(revs[0]);

            return (
                    <BootstrapTable
                            ref={'rev-table-' + row.RowId}
                            data={revs}
                            selectRow={this.selectInnerRowProp}
                            cellEdit={this.getCellEditProps()}
                    >
                        <TableHeaderColumn dataField='RevisionNum' width='50px' isKey={true}>Rev</TableHeaderColumn>
                        <TableHeaderColumn dataField='Description'>Description</TableHeaderColumn>
                        <TableHeaderColumn dataField='RowId' hidden/>
                    </BootstrapTable>
            )
        }).apply(this))
    }

    isExpandableRow(row) {
        return true;
    }

    onRowSelect = (row, isSelected, e) => {
        return ((() => {
            if (isSelected) {
                console.log('selected: ' + row)
                this.state = {

                };
            }
        }).apply(this))
    }

    selectRowProp = {
        mode: 'checkbox',
        clickToExpand: true
    };

    getExpandedTimelineIds = () => {
        return this.refs["timeline-table"].state.expanding;
    }

    setExpandedTimelineId = (id) => {
        this.refs["timeline-table"].setState({
            expanding: [id]
        });
    }


    getCellEditProps = () => {
        return ((() => {
            let me = this;
            return {
                mode: 'dbclick',
                blurToSave: true,
                nonEditableRows: function () {

                    // Only selected timelines can edit their names
                    let expanded = me.getExpandedTimelineIds();
                    let nonEdit = [];
                    let timelineTable = me.refs["timeline-table"];

                    // Look at expanded subtable
                    if (timelineTable != null && expanded.length > 0) {
                        for (const revTableRef in timelineTable.body.refs) {
                            if (timelineTable.body.refs.hasOwnProperty(revTableRef)) {
                                let timelineId = revTableRef.split('-')[2];

                                // Only look at selections in expanded subtable
                                if (expanded[0] === parseInt(timelineId)) {
                                    let revTable = timelineTable.body.refs[revTableRef];
                                    let selections = revTable.state.selectedRowKeys;

                                    // Add keys for any rows not selected
                                    for (const row of revTable.state.data) {
                                        if (selections.length < 1 || selections[0] !== row.RevisionNum || me.props.selectedTimeline.QcState !== 4) {
                                            nonEdit.push(row.RevisionNum)
                                        }
                                    }


                                }
                            }
                        }

                    }

                    return nonEdit;
                },
                afterSaveCell: function(row, cellName, cellValue) {
                    const updatedTimeline = Object.assign({}, me.props.selectedTimeline, {
                        Description: cellValue,
                        IsDirty: true
                    });
                    me.props.onUpdateTimeline(updatedTimeline);

                    return true;
                }
            }
        }).apply(this))
    }


    selectInnerRowProp = {
        mode: 'radio',
        clickToSelect: true,
        onSelect: this.onTimelineRowsSelected,
        selected: [0]
    };

    options = {
        expandRowBgColor: 'rgb(249, 249, 209)',
        onlyOneExpanding: true,
        defaultSortName: 'Description',
        defaultSortOrder: 'asc',
        noDataText: 'No timelines available'
    };

    deselectAllTimelines = () => {
        const timelineTable = this.refs['timeline-table'];

        if (timelineTable) {
            for (const revTable in timelineTable.body.refs) {
                if (timelineTable.body.refs.hasOwnProperty(revTable)) {
                    timelineTable.body.refs[revTable].state.selectedRowKeys = [];
                }
            }
        }

        this.props.onSelectTimeline({});
    }

    expandColumnComponent = ({ isExpandableRow, isExpanded }) => {
        return ((() => {
            let content = '';

            if (isExpandableRow) {
                content = (isExpanded ? <FontAwesomeIcon icon={["fa", "caret-down"]} size={"lg"}/> :
                        <FontAwesomeIcon icon={["fa", "caret-right"]} size={"lg"}/>);
            }
            else {
                content = ' ';
            }
            return (
                    <div> {content} </div>
            );
        }).apply(this));
    }

    render = () => {
        this.state.revTableCount = 0;

        // let projectCount = this.props.timelines ? this.props.timelines.length : 0;
        return <div>
        <div className="input-group bottom-padding-8">
            <OverlayTrigger placement="top" overlay={this.getTooltip("New timeline")}>
                <Button
                        className='scheduler-timeline-list-btn'
                        onClick={this.newTimeline}
                ><FontAwesomeIcon icon={["fa", "plus"]}/></Button>
            </OverlayTrigger>
            <OverlayTrigger placement="top" overlay={this.getTooltip("Timeline revision")}>
                <Button
                        className='scheduler-timeline-list-btn'
                        // onClick={this.onAddClick}
                ><FontAwesomeIcon icon={["fa", "copy"]}/></Button>
            </OverlayTrigger>
            <OverlayTrigger placement="top" overlay={this.getTooltip("Timeline clone")}>
                <Button
                        className='scheduler-timeline-list-btn'
                        // onClick={this.onAddClick}
                ><FontAwesomeIcon icon={["fa", "clone"]}/></Button>
            </OverlayTrigger>
        </div>
        <div className='col-sm-12 scheduler-timeline-list'>
            <BootstrapTable
                    ref='timeline-table'
                    className='timeline-table'
                    data={this.props.timelines}
                    options={this.options}
                    // selectRow={this.selectRowProp}
                    height={243}
                    expandableRow={this.isExpandableRow}
                    expandComponent={this.expandComponent}
                    expandColumnOptions={{
                        expandColumnVisible: true,
                        expandColumnComponent: this.expandColumnComponent,
                        columnWidth: 25
                    }}
                    // cellEdit={ this.cellEditProp }
            >
                <TableHeaderColumn dataField='RowId' isKey={true} hidden />
                <TableHeaderColumn
                        dataField='Description'
                        className='scheduler-timeline-list-hdr'
                        dataSort={ true }
                >Description</TableHeaderColumn>
            </BootstrapTable>
        </div>
    </div>
    }

  }

TimelineList.propTypes = {
    onSelectTimeline: PropTypes.func.isRequired
}

const mapStateToProps = state => ({
    selectedProject: state.project.selectedProject || null,
    selectedTimeline: (state.project.selectedProject != null) ? state.timeline.selectedTimeline : null,
    timelines: state.timeline.timelines  || null
})

const mapDispatchToProps = dispatch => ({
    onSelectTimeline: selectedTimeline => dispatch(selectTimeline(selectedTimeline)),
    onNewTimeline: (timeline, selectedProject) => dispatch(newTimeline(timeline, selectedProject)),
    onUpdateTimeline: selectedProject => dispatch(updateSelectedTimeline(selectedProject))
})

export default connect(
        mapStateToProps,
        mapDispatchToProps
)(TimelineList)