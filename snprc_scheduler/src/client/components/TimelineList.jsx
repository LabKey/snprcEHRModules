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
import { DataGrid, textEditor } from 'react-data-grid';
import {
    selectTimeline,
    duplicateTimeline,
    newTimeline,
    updateSelectedTimeline,
    cloneTimeline,
    reviseTimeline,
    showConfirm,
    hideConfirm,
    deleteNewTimelines,
    getNextRowId,
    showAlertModal,
    hideAlertModal,
    TAB_TIMELINES,
    saveTimeline,
    showAlertBanner,
    fetchTimelinesByProject
} from '../actions/dataActions';
import PropTypes from "prop-types";
import { connect } from "react-redux";
import { Button, OverlayTrigger, Tooltip } from "react-bootstrap";

import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { library } from '@fortawesome/fontawesome-svg-core'
import { faCopy, faClone, faCaretDown, faCaretRight, faTrash, faPlus, faPencil } from '@fortawesome/free-solid-svg-icons';

library.add(faCopy);
library.add(faClone);
library.add(faCaretDown);
library.add(faCaretRight);
library.add(faTrash);
library.add(faPlus);
library.add(faPencil);

const verboseOutput = false;

class TimelineList extends React.Component {
    
    constructor(props) {
        super(props);
        this.state = {
            debugUI: false,
            expandedTimelineIds: new Set(),
            confirmed: false
        };
        this.gridRef = React.createRef();
    }

    getTooltip = (label) => {
        return (<Tooltip id="tooltip">
            {label}
        </Tooltip>)
    }

    onCellClick = (args, event) => {
        const { selectedTimeline, onSelectTimeline, showConfirm, hideConfirm, deleteNewTimelines } = this.props;
        const row = args.row;

        // Handle expand/collapse click on expand column
        if (args.column.key === 'expand') {
            this.toggleExpand(row.RowId);
            return;
        }

        // Handle timeline selection
        if (selectedTimeline && selectedTimeline.IsDirty && (row.RowId !== selectedTimeline.RowId || row.RevisionNum !== selectedTimeline.RevisionNum)) {
            showConfirm({
                title: 'Unsaved Data',
                msg: 'Opening another timeline will lose unsaved data on this timeline, including the timeline itself ' +
                        'if it is not saved. Proceed without saving?',
                onConfirm: () => {
                    deleteNewTimelines();
                    onSelectTimeline(row);
                    hideConfirm();
                    if (row.RevisionNum === 0) {
                        this.expandTimeline(row.RowId);
                    }
                },
                onCancel: () => {
                    hideConfirm();
                }
            })
        }
        else {
            onSelectTimeline(row);
            if (row.RevisionNum === 0) {
                this.expandTimeline(row.RowId);
            }
        }
    };

    toggleExpand = (rowId) => {
        this.setState(state => {
            const expandedTimelineIds = new Set(state.expandedTimelineIds);
            if (expandedTimelineIds.has(rowId)) {
                expandedTimelineIds.delete(rowId);
            } else {
                expandedTimelineIds.clear(); // Only one expanding at a time
                expandedTimelineIds.add(rowId);
            }
            return { expandedTimelineIds };
        });
    };

    expandTimeline = (rowId) => {
        this.setState({
            expandedTimelineIds: new Set([rowId])
        });
    };

    newTimelineConfirm = () => {
        const { selectedTimeline, hideConfirm, showConfirm, deleteNewTimelines } = this.props;

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
                }
            })
        }
        else {
            this.newTimeline();
        }
    }

    newTimeline = () => {
        const { selectedProject, timelines, lastRowId, onNewTimeline } = this.props;

        let newTimeline = {
            ProjectId: selectedProject.projectId,
            ProjectObjectId: selectedProject.ProjectObjectId,
        };

        onNewTimeline(newTimeline, selectedProject);
        const newRowId = getNextRowId(lastRowId, timelines);
        this.expandTimeline(newRowId);
        
        // Enable edit mode for the description field of the new timeline
        // Use setTimeout to ensure the grid has rendered the new row
        setTimeout(() => {
            if (this.gridRef.current) {
                const rows = this.getTimelineRows();
                const rowIdx = rows.findIndex(r => r.RowId === newRowId && r.RevisionNum === 0);
                if (rowIdx !== -1) {
                    const descriptionColumnIdx = 2;
                    this.gridRef.current.selectCell(
                        { idx: descriptionColumnIdx, rowIdx },
                        { enableEditor: true }
                    );
                }
            }
        }, 100);
    };

    cloneTimelineConfirm = () => {
        const { selectedTimeline, hideConfirm, showConfirm, deleteNewTimelines } = this.props;

        if (selectedTimeline) {
            if (selectedTimeline.IsDirty) {
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
                    }
                })
            }
            else {
                this.cloneTimeline();
            }
        }
    };

    cloneTimeline = () => {
        const { selectedTimeline, timelines, lastRowId, onCloneTimeline } = this.props;
        onCloneTimeline(selectedTimeline);
        const newRowId = getNextRowId(lastRowId, timelines);
        this.expandTimeline(newRowId);
    };

    reviseTimelineConfirm = () => {
        const { selectedTimeline, hideConfirm, showConfirm, showAlert, hideAlert, deleteNewTimelines } = this.props;

        if (selectedTimeline) {
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
                    }
                })
            }
            else {
                this.reviseTimeline();
            }
        }
    };

    reviseTimeline = () => {
        const { selectedTimeline, timelines, showAlert, hideAlert, onReviseTimeline } = this.props;
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

        onReviseTimeline(latestRev ? latestRev : selectedTimeline);
    };

    deleteTimelineValidate = () => {
        const { showConfirm, hideConfirm, selectedTimeline, timelines, showAlert, hideAlert } = this.props;

        if (selectedTimeline) {
            if (selectedTimeline.IsInUse) {
                showAlert({
                    title: 'Delete Error',
                    msg: 'Cannot delete ' + selectedTimeline.Description + ', ' + selectedTimeline.RevisionNum + ', it is in use.',
                    onDismiss: () => {
                        hideAlert();
                    }
                })
            }
            else if (selectedTimeline.QcStateLabel !== "In Progress") {
                showAlert({
                    title: 'Delete Error',
                    msg: 'Cannot delete ' + selectedTimeline.Description + ', ' + selectedTimeline.RevisionNum + ', it is not in draft state. ' +
                            'Only timelines saved as draft can be deleted.',
                    onDismiss: () => {
                        hideAlert();
                    }
                })
            }
            else {
                const laterTls = timelines.filter(tl => {
                    return (tl.TimelineId === selectedTimeline.TimelineId && tl.RevisionNum > selectedTimeline.RevisionNum)
                });
                if (laterTls.length > 0) {
                    showAlert({
                        title: 'Delete Error',
                        msg: 'Cannot delete ' + selectedTimeline.Description + ', ' + selectedTimeline.RevisionNum + ', it has a later timeline revision.',
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
        }
    };

    deleteSelectedTimeline = () => {

        const { showAlertBanner, selectedTimeline, fetchTimelines, selectedProject } = this.props;

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
                // console.log('save timeline succeeded');
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


    ExpandFormatter = ({ row }) => {
        if (!row.isParent) {
            return <div style={{ paddingLeft: '25px' }} />;
        }
        
        if (!row.hasChildren) {
            return <div />;
        }

        const icon = row.isExpanded ? 
            <FontAwesomeIcon icon={faCaretDown} size="lg" /> : 
            <FontAwesomeIcon icon={faCaretRight} size="lg" />;
        
        return <div style={{ cursor: 'pointer' }}>{icon}</div>;
    };

    RevisionFormatter = ({ row }) => {
        return <div style={{ paddingLeft: '25px' }}>{row.RevisionNum}</div>;
    };

    DescriptionFormatter = ({ row }) => {
        const { selectedTimeline } = this.props;
        const isSelected = selectedTimeline && 
                          selectedTimeline.RowId === row.RowId && 
                          selectedTimeline.RevisionNum === row.RevisionNum;
        const style = row.isChild ? { paddingLeft: '25px', display: 'flex', alignItems: 'center', gap: '8px' } : { display: 'flex', alignItems: 'center', gap: '8px' };
        return (
            <div style={style}>
                <span style={{ flex: 1 }}>{row.Description || ''}</span>
                {isSelected && (
                    <FontAwesomeIcon 
                        icon={faPencil} 
                        style={{ cursor: 'pointer', color: '#666' }}
                        onClick={(e) => {
                            e.stopPropagation();
                            this.enableEditMode(row);
                        }}
                        title="Edit description"
                    />
                )}
            </div>
        );
    };

    enableEditMode = (row) => {
        if (this.gridRef.current) {
            const rows = this.getTimelineRows();
            const rowIdx = rows.findIndex(r =>
                    r.RowId === row.RowId && r.RevisionNum === row.RevisionNum
                );

            const descriptionColumnIdx = 2;
            this.gridRef.current.selectCell(
                    { idx: descriptionColumnIdx, rowIdx },
                    { enableEditor: true }
            );
        }
    };

    getColumns = () => {
        return [
            { 
                key: 'expand', 
                name: '', 
                width: 30,
                renderCell: this.ExpandFormatter,
                frozen: true
            },
            { 
                key: 'RevisionNum', 
                name: 'Rev', 
                width: 50,
                renderCell: this.RevisionFormatter
            },
            { 
                key: 'Description', 
                name: 'Description', 
                renderCell: this.DescriptionFormatter,
                renderEditCell: textEditor,
                editable: (row) => {
                    const { selectedTimeline } = this.props;
                    return selectedTimeline && 
                           selectedTimeline.RowId === row.RowId && 
                           selectedTimeline.RevisionNum === row.RevisionNum;
                }
            }
        ];
    };

    getGridKey = () => {
        return Math.random();
    };

    onRowsChange = (rows, data) => {
        // Handle cell edit
        const { column, indexes } = data;
        
        if (column.key === 'Description') {
            const rowIndex = indexes[0];
            const updatedRow = rows[rowIndex];
            
            const updatedTimeline = Object.assign({}, this.props.selectedTimeline, {
                Description: updatedRow.Description,
                IsDirty: true
            });
            this.props.onUpdateTimeline(updatedTimeline, true);

            const stateCopy = {
                rows: [...rows],
                key: this.getGridKey()
            };
            this.setState(stateCopy);
        }
    };

    rowClass = (row) => {
        const { selectedTimeline } = this.props;
        
        if (selectedTimeline && 
            selectedTimeline.RowId === row.RowId && 
            selectedTimeline.RevisionNum === row.RevisionNum) {
            return 'rdg-row-selected';
        }
        
        if (row.isChild) {
            return 'rdg-row-child';
        }
        
        return '';
    };

    getTimelineRows = () => {
        const { timelines, selectedTimeline } = this.props;
        const { expandedTimelineIds } = this.state;

        if (!timelines || timelines.length === 0) {
            return [];
        }

        const rows = [];
        
        // Group timelines by RowId
        const timelineGroups = {};
        timelines.forEach(timeline => {
            // Use selectedTimeline if it matches the current timeline
            const timelineToUse = selectedTimeline && 
                                  selectedTimeline.RowId === timeline.RowId && 
                                  selectedTimeline.RevisionNum === timeline.RevisionNum
                ? selectedTimeline
                : timeline;
            
            if (!timelineGroups[timelineToUse.RowId]) {
                timelineGroups[timelineToUse.RowId] = [];
            }
            timelineGroups[timelineToUse.RowId].push(timelineToUse);
        });

        // For each timeline group, add parent row (RevisionNum 0) and child rows if expanded
        Object.keys(timelineGroups).forEach(rowId => {
            const group = timelineGroups[rowId];
            
            // Sort by revision number ascending
            group.sort((a, b) => a.RevisionNum - b.RevisionNum);
            
            // Add parent row (RevisionNum 0)
            const parent = group.find(t => t.RevisionNum === 0);
            if (parent) {
                rows.push({
                    ...parent,
                    isParent: true,
                    isExpanded: expandedTimelineIds.has(parent.RowId),
                    hasChildren: group.length > 1
                });
                
                // Add child rows if expanded
                if (expandedTimelineIds.has(parent.RowId)) {
                    group.forEach(timeline => {
                        if (timeline.RevisionNum !== 0) {
                            rows.push({
                                ...timeline,
                                isParent: false,
                                isChild: true
                            });
                        }
                    });
                }
            }
        });

        return rows;
    };

    render = () => {
        const { selectedTimeline } = this.props;
        const rows = this.getTimelineRows();
        const columns = this.getColumns();

        return <div>
            <div className="input-group top-bottom-padding-8">
                <OverlayTrigger placement="top" overlay={this.getTooltip("New timeline")}>
                    <Button
                        variant="light"
                        className='scheduler-timeline-list-btn'
                        onClick={this.newTimelineConfirm}
                    ><FontAwesomeIcon icon={faPlus}/></Button>
                </OverlayTrigger>
                <OverlayTrigger placement="top" overlay={this.getTooltip("Timeline revision")}>
                    <Button
                        variant="light"
                        className='scheduler-timeline-list-btn'
                        onClick={this.reviseTimelineConfirm}
                        disabled={!selectedTimeline || !selectedTimeline.ObjectId}
                    ><FontAwesomeIcon icon={faCopy}/></Button>
                </OverlayTrigger>
                <OverlayTrigger placement="top" overlay={this.getTooltip("Timeline clone")}>
                    <Button
                        variant="light"
                        className='scheduler-timeline-list-btn'
                        onClick={this.cloneTimelineConfirm}
                        disabled={!selectedTimeline}
                    ><FontAwesomeIcon icon={faClone}/></Button>
                </OverlayTrigger>
                <OverlayTrigger placement="top" overlay={this.getTooltip("Delete timeline")}>
                    <Button
                        variant="light"
                        className='scheduler-timeline-list-btn'
                        onClick={this.deleteTimelineValidate}
                        disabled={!selectedTimeline || !selectedTimeline.ObjectId}
                    ><FontAwesomeIcon icon={faTrash}/></Button>
                </OverlayTrigger>
            </div>
            <div className='col-sm-12 scheduler-timeline-list'>
                <DataGrid
                    ref={this.gridRef}
                    className='timeline-table'
                    columns={columns}
                    rows={rows}
                    rowKeyGetter={(row) => `${row.RowId}_${row.RevisionNum}`}
                    onCellClick={this.onCellClick}
                    onRowsChange={this.onRowsChange}
                    rowClass={this.rowClass}
                    style={{ height: 'calc(51vh - 160px - 50px)' }}
                    defaultColumnOptions={{ resizable: true }}
                />
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
    accordion: state.root.accordion,
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
    showAlertBanner: timeline => dispatch(showAlertBanner(timeline)),
    fetchTimelines: selectedProject => dispatch(fetchTimelinesByProject(selectedProject))
})

export default connect(
        mapStateToProps,
        mapDispatchToProps
)(TimelineList)