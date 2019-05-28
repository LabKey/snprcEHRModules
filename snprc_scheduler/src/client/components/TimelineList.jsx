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
    updateSelectedTimeline,
    cloneTimeline,
    reviseTimeline,
    showConfirm,
    hideConfirm,
    deleteNewTimelines,
    getNextRowId,
    setTimelineClean,
    showAlertModal,
    hideAlertModal,
    TAB_TIMELINES,
    TAB_PROJECTS,
    saveTimeline,
    hideAlertBanner,
    showAlertBanner, fetchTimelinesByProject
} from '../actions/dataActions';
import PropTypes from "prop-types";
import connect from "react-redux/es/connect/connect";
import {Button, OverlayTrigger, Tooltip} from "react-bootstrap";

import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { library } from '@fortawesome/fontawesome-svg-core'
import { faCopy, faClone, faCaretDown, faCaretRight, faTrash } from '@fortawesome/free-solid-svg-icons';

library.add(faCopy);
library.add(faClone);
library.add(faCaretDown);
library.add(faCaretRight);
library.add(faTrash);

const verboseOutput = false;

class TimelineList extends React.Component {
    
    constructor(props) {
        super(props);
        this.state = {
            debugUI: false,
            timelineCols: [
                { key: 'Description', name: 'Description', editable: true, width: 400 }
            ],
            // selectedTimelines: [],
            selectedTimeline: (this.props.selectedTimeline || null),
            revTableCount: 0,
            expanding: [],
            confirmed: false
        };
    }

    shouldComponentUpdate(nextProps, nextState, nextContext) {
        const { accordion } = this.props;

        return true;
        // return !!(accordion && accordion.tab === TAB_TIMELINES);
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
        const { selectedTimeline, onSelectTimeline, cleanTimeline, showConfirm, hideConfirm, deleteNewTimelines } = this.props;

        return ((() => {
            if (selectedTimeline && selectedTimeline.IsDirty) {
                showConfirm({
                    title: 'Unsaved Data',
                    msg: 'Opening another timeline will lose unsaved data on this timeline, including the timeline itself ' +
                            'if it is not saved. Proceed without saving?',
                    onConfirm: () => {
                        deleteNewTimelines();
                        if (isSelected) {
                            onSelectTimeline(row);
                        }
                        hideConfirm();
                        this.setExpandedTimelineId(row.RowId);
                    },
                    onCancel: () => {
                        hideConfirm();
                        this.setExpandedTimelineId(selectedTimeline.RowId);
                    }
                })
            }
            else {
                if (isSelected) {
                    onSelectTimeline(row);
                }
            }

        }).apply(this))
    };

    newTimelineConfirm = () => {
        const { selectedTimeline, hideConfirm, showConfirm, cleanTimeline, deleteNewTimelines } = this.props;

        if (selectedTimeline && selectedTimeline.IsDirty) {
            showConfirm({
                title: 'Unsaved Data',
                msg: 'Opening another timeline will lose unsaved data on this timeline, including the timeline itself ' +
                        'if it is not saved. Proceed without saving?',
                onConfirm: () => {
                    deleteNewTimelines();
                    this.newTimeline();
                    hideConfirm();
                },
                onCancel: () => {
                    hideConfirm();
                    this.setExpandedTimelineId(selectedTimeline.RowId);
                }
            })
        }
        else {
            this.newTimeline();
        }
    }

    newTimeline = () => {
        const { selectedProject, timelines, lastRowId } = this.props;

        return ((() => {

            let newTimeline = {
                ProjectId: selectedProject.projectId,
                ProjectObjectId: selectedProject.ProjectObjectId,
            };

            this.props.onNewTimeline(newTimeline, selectedProject);
            this.setExpandedTimelineId(getNextRowId(lastRowId, timelines));

        }).apply(this))
    };

    cloneTimelineConfirm = () => {
        const { selectedTimeline, hideConfirm, showConfirm, cleanTimeline, deleteNewTimelines } = this.props;

        if (selectedTimeline && selectedTimeline.IsDirty) {
            showConfirm({
                title: 'Unsaved Data',
                msg: 'Opening another timeline will lose unsaved data on this timeline, including the timeline itself ' +
                        'if it is not saved. Proceed without saving?',
                onConfirm: () => {
                    deleteNewTimelines();
                    this.cloneTimeline();
                    hideConfirm();
                },
                onCancel: () => {
                    hideConfirm();
                    this.setExpandedTimelineId(selectedTimeline.RowId);
                }
            })
        }
        else {
            this.cloneTimeline();
        }
    };

    cloneTimeline = () => {
        const { selectedTimeline, timelines, lastRowId } = this.props;
        this.props.onCloneTimeline(selectedTimeline);
        this.setExpandedTimelineId(getNextRowId(lastRowId, timelines));
    };

    reviseTimelineConfirm = () => {
        const { selectedTimeline, hideConfirm, showConfirm, showAlert, hideAlert, cleanTimeline, deleteNewTimelines } = this.props;

        if (!selectedTimeline.ObjectId) {
            showAlert({
                title: 'Revision Error',
                msg: 'Cannot create a new revision from an unsaved timeline revision. Save current timeline revision first.',
                onDismiss: () => {
                    hideAlert();
                }
            })
        }
        else if (selectedTimeline && selectedTimeline.IsDirty) {
            showConfirm({
                title: 'Unsaved Data',
                msg: 'Opening another timeline will lose unsaved data on this timeline, including the timeline itself ' +
                        'if it is not saved. Proceed without saving?',
                onConfirm: () => {
                    deleteNewTimelines();
                    this.reviseTimeline();
                    hideConfirm()
                },
                onCancel: () => {
                    hideConfirm();
                    this.setExpandedTimelineId(selectedTimeline.RowId);
                }
            })
        }
        else {
            this.reviseTimeline();
        }
    };

    reviseTimeline = () => {
        const { selectedTimeline, timelines, showAlert, hideAlert } = this.props;
        let latestRev;
        timelines.forEach((tl) => {
            if (tl.TimelineId === selectedTimeline.TimelineId && tl.RevisionNum > selectedTimeline.RevisionNum) {
                if (!latestRev || latestRev.RevisionNum < tl.RevisionNum) {
                    latestRev = tl;
                }
            }
        });

        if (latestRev) {
            showAlert({
                title: 'Timeline Revision',
                msg: 'Revisions can only be created from last revision of a timeline. Revision created from revision ' + latestRev.RevisionNum + '.',
                onDismiss: () => {
                    hideAlert();
                }
            })
        }

        this.props.onReviseTimeline(latestRev ? latestRev : selectedTimeline);
    };

    deleteTimelineValidate = () => {
        const { showConfirm, hideConfirm, selectedTimeline, timelines, showAlert, hideAlert } = this.props;

        if (selectedTimeline.IsInUse) {
            showAlert({
                title: 'Delete Error',
                msg: 'Cannot delete ' + selectedTimeline.Description + ', ' +  selectedTimeline.RevisionNum + ', it is in use.',
                onDismiss: () => {
                    hideAlert();
                }
            })
        }
        else if (!selectedTimeline.IsDraft) {
            showAlert({
                title: 'Delete Error',
                msg: 'Cannot delete ' + selectedTimeline.Description + ', ' +  selectedTimeline.RevisionNum + ', it is not in draft state. ' +
                        'Only timelines saved as draft can be deleted.',
                onDismiss: () => {
                    hideAlert();
                }
            })
        }
        else {
            const laterTls = timelines.filter(tl => { return (tl.TimelineId === selectedTimeline.TimelineId && tl.RevisionNum > selectedTimeline.RevisionNum) });
            if (laterTls.length > 0) {
                showAlert({
                    title: 'Delete Error',
                    msg: 'Cannot delete ' + selectedTimeline.Description + ', ' +  selectedTimeline.RevisionNum + ', it has a later timeline revision.',
                    onDismiss: () => {
                        hideAlert();
                    }
                })
            }
            else {
                showConfirm({
                    title: 'Delete timeline',
                    msg: 'Permanently delete timeline?',
                    onConfirm: () => {
                        this.deleteSelectedTimeline();
                        hideConfirm()
                    },
                    onCancel: () => {
                        hideConfirm();
                    }
                })
            }
        }
    };

    deleteSelectedTimeline = () => {

        const {showAlertBanner, selectedTimeline, fetchTimelines, selectedProject} = this.props;

        selectedTimeline.IsDeleted = true;

        saveTimeline(selectedTimeline).then((response) => {

            if (!response.success) {
                if (response.responseText) {
                    showAlertBanner({
                        variant: 'danger', msg: "Error deleting " + selectedTimeline.Description +
                                ", revision " + selectedTimeline.RevisionNum + ": " + response.responseText
                    });
                    console.warn('delete timeline error', response.responseText);
                }
                else {
                    showAlertBanner({
                        variant: 'danger', msg: "Error deleting " + selectedTimeline.Description +
                                ", revision " + selectedTimeline.RevisionNum + ": Success value false"
                    });
                    console.warn('delete timeline error', "success value false");
                }
            }
            else {
                console.log('save timeline succeeded');
                showAlertBanner({
                    variant: 'success',
                    msg: selectedTimeline.Description + ", revision " + selectedTimeline.RevisionNum +
                            " deleted successfully."
                });
                fetchTimelines(selectedProject);
            }

        }).catch((error) => {
            this.setState(state => {
                state.showSaving = false;
                return state;
            });

            if (error.exception) {
                showAlertBanner({
                    variant: 'danger', msg: "Error deleting " + selectedTimeline.Description +
                            ", revision " + selectedTimeline.RevisionNum + ": " + error.exception
                });
                console.warn('delete timeline error', error.exception);
            }
            else if (error.errors) {
                showAlertBanner({
                    variant: 'danger', msg: "Error deleting " + selectedTimeline.Description +
                            ", revision " + selectedTimeline.RevisionNum + ": " + error.errors[0].msg
                });
                console.warn('delete timeline error', error.errors[0].msg);
            }
            else if (error.message) {
                showAlertBanner({
                    variant: 'danger', msg: "Error deleting " + selectedTimeline.Description +
                            ", revision " + selectedTimeline.RevisionNum + ": " + error.message
                });
                console.warn('delete timeline error', error.message);
            }
        });

    };

    innerOptions = {
        defaultSortName: 'RevisionNum',
        defaultSortOrder: 'asc',
    }

    expandComponent = (row) => {
        const { selectedTimeline, timelines, accordion } = this.props;

        return ((() => {

            if (accordion && accordion.tab === TAB_TIMELINES) {

                let revs = [];

                for (const timeline of timelines) {
                    if (timeline.RowId && timeline.RowId === row.RowId) {
                        revs.push(timeline);
                    }
                }

                revs = revs.sort(function (a, b) {
                    return (a.RevisionNum < b.RevisionNum ? 1 : -1)
                });

                this.state.revTableCount++;

                const expanded = this.getExpandedTimelineIds();
                if (selectedTimeline && row.RowId === selectedTimeline.RowId && selectedTimeline.RowId !== expanded[0])
                    this.setExpandedTimelineId(selectedTimeline.RowId);

                return (
                        <BootstrapTable
                                ref={'rev-table-' + row.RowId}
                                data={revs}
                                options={this.innerOptions}
                                selectRow={this.getInnerRowProps(selectedTimeline.RevisionNum)}
                                cellEdit={this.getCellEditProps()}
                        >
                            <TableHeaderColumn dataField='RevisionNum' width='50px' isKey={true}>Rev</TableHeaderColumn>
                            <TableHeaderColumn dataField='Description'>Description</TableHeaderColumn>
                            <TableHeaderColumn dataField='RowId' hidden/>
                        </BootstrapTable>
                )
            }
            return null;
        }).apply(this))
    };

    isExpandableRow(row) {
        return true;
    }

    handleExpand = (rowKey, isExpand, e) => {
        const {selectedTimeline, onSelectTimeline, hideConfirm, showConfirm, deleteNewTimelines, timelines} = this.props;

        if (isExpand) {
            if (selectedTimeline && selectedTimeline.IsDirty && !this.state.confirmed) {
                showConfirm({
                    title: 'Unsaved Data',
                    msg: 'Opening another timeline will lose unsaved data on this timeline, including the timeline ' +
                            'itself if it is not saved. Proceed without saving?',
                    onConfirm: () => {
                        // Delete unsaved timelines if navigating away
                        deleteNewTimelines();
                        onSelectTimeline(timelines.find((timeline) => {
                            return (timeline.RowId === rowKey && timeline.RevisionNum === 0)
                        }));
                        hideConfirm();
                        this.setExpandedTimelineId(rowKey);
                    },
                    onCancel: () => {
                        hideConfirm();
                        this.setExpandedTimelineId(selectedTimeline.RowId);
                    }
                });
                this.setExpandedTimelineId(selectedTimeline.RowId);
            }
            else {
                if (this.state.confirmed) {
                    this.setState({confirmed: false});
                }

                onSelectTimeline(timelines.find((timeline) => {
                    return (timeline.RowId === rowKey && timeline.RevisionNum === 0)
                }));
            }
        }
        else {
            this.setExpandedTimelineId(selectedTimeline.RowId);
        }

    };

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
    };

    setExpandedTimelineId = (id) => {
        this.refs["timeline-table"].setState({
            expanding: [id]
        });
    };

    clearExpandedTimelines = () => {
        this.refs["timeline-table"].setState({
            expanding: []
        });
    };

    setSelectedRevision = (timelineId, revNum) => {
        const timelineTable = this.refs['timeline-table'];
        if (timelineTable) {
            const revTable = timelineTable.body.refs['rev-table-' + timelineId];
            if (revTable) {
                revTable.setState({
                    selectedRowKeys: [revNum]
                })
            }
        }
    };

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
                    me.props.onUpdateTimeline(updatedTimeline, true);

                    return true;
                }
            }
        }).apply(this))
    }


    getInnerRowProps = (rev) => {
        return {
            mode: 'radio',
            clickToSelect: true,
            onSelect: this.onTimelineRowsSelected,
            selected: [rev]
        };
    };

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
    };

    getTimelineRows = () => {
        const { timelines } = this.props;

        if (timelines) {
            return timelines.filter(timeline => timeline.RevisionNum === 0)
        }

        return timelines;
    };

    render = () => {
        this.state.revTableCount = 0;
        const options = {
            expandRowBgColor: 'rgb(249, 249, 209)',
            onlyOneExpanding: true,
            defaultSortName: 'Description',
            defaultSortOrder: 'asc',
            noDataText: 'No timelines available',
            // expanding: this.state.expanding,
            onExpand: this.handleExpand
        };

        // let projectCount = this.props.timelines ? this.props.timelines.length : 0;
        return <div>
        <div className="input-group bottom-padding-8">
            <OverlayTrigger placement="top" overlay={this.getTooltip("New timeline")}>
                <Button
                        className='scheduler-timeline-list-btn'
                        onClick={this.newTimelineConfirm}
                ><FontAwesomeIcon icon={["fa", "plus"]}/></Button>
            </OverlayTrigger>
            <OverlayTrigger placement="top" overlay={this.getTooltip("Timeline revision")}>
                <Button
                        className='scheduler-timeline-list-btn'
                        onClick={this.reviseTimelineConfirm}
                ><FontAwesomeIcon icon={["fa", "copy"]}/></Button>
            </OverlayTrigger>
            <OverlayTrigger placement="top" overlay={this.getTooltip("Timeline clone")}>
                <Button
                        className='scheduler-timeline-list-btn'
                        onClick={this.cloneTimelineConfirm}
                ><FontAwesomeIcon icon={["fa", "clone"]}/></Button>
            </OverlayTrigger>
            <OverlayTrigger placement="top" overlay={this.getTooltip("Delete timeline")}>
                <Button
                        className='scheduler-timeline-list-btn'
                        onClick={this.deleteTimelineValidate}
                ><FontAwesomeIcon icon={["fa", "trash"]}/></Button>
            </OverlayTrigger>
        </div>
        <div className='col-sm-12 scheduler-timeline-list'>
            <BootstrapTable
                    ref='timeline-table'
                    className='timeline-table'
                    data={this.getTimelineRows()}
                    options={options}
                    // selectRow={this.selectRowProp}
                    height={243}
                    expandableRow={this.isExpandableRow}
                    expandComponent={this.expandComponent}
                    // expandComponent={this.expandComponentConfirm}
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
    timelines: state.timeline.timelines  || null,
    lastRowId: state.timeline.lastRowId,
    accordion: state.root.accordion
})

const mapDispatchToProps = dispatch => ({
    onSelectTimeline: selectedTimeline => dispatch(selectTimeline(selectedTimeline)),
    onNewTimeline: (timeline, selectedProject) => dispatch(newTimeline(timeline, selectedProject)),
    onCloneTimeline: (timeline) => dispatch(cloneTimeline(timeline)),
    onReviseTimeline: (timeline) => dispatch(reviseTimeline(timeline)),
    deleteNewTimelines: (timeline) => dispatch(deleteNewTimelines(timeline)),
    onUpdateTimeline: (timeline, dirty) => dispatch(updateSelectedTimeline(timeline, dirty)),
    showConfirm: confirm => dispatch(showConfirm(confirm)),
    hideConfirm: confirm => dispatch(hideConfirm(confirm)),
    showAlert: alert => dispatch(showAlertModal(alert)),
    hideAlert: alert => dispatch(hideAlertModal(alert)),
    hideAlertBanner: timeline => dispatch(hideAlertBanner(timeline)),
    showAlertBanner: timeline => dispatch(showAlertBanner(timeline)),
    cleanTimeline: timeline => dispatch(setTimelineClean(timeline)),
    fetchTimelines: selectedProject => dispatch(fetchTimelinesByProject(selectedProject))
})

export default connect(
        mapStateToProps,
        mapDispatchToProps
)(TimelineList)