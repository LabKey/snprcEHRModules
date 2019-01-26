import React from "react";
import ReactDataGrid from "react-data-grid";
import {Button, Modal, OverlayTrigger, Tooltip} from "react-bootstrap";
import DraggableContainer from "./dnd/DraggableContainer";
import PropTypes from "prop-types";
import {
    addTimelineItem, assignTimelineProcedure, deleteTimelineItem,
    selectTimeline,
    updateSelectedTimeline,
    updateTimelineItem, updateTimelineProjectItem,
    updateTimelineRow
} from "../actions/dataActions";
import connect from "react-redux/es/connect/connect";


function MyCustomHeader(props) {
    let cls = 'procedure-tl-grid-hdr';
    if (props.type === 'studyDay') {
        cls = 'day-tl-grid-hdr';
    }
    else if (props.type === 'schedDate') {
        cls = 'time-tl-grid-hdr';
    }
    else {
        const tooltip = (
                <Tooltip id="tooltip">
                    {props.column.rawName}
                </Tooltip>
        );

        return (
                <OverlayTrigger placement="top" overlay={tooltip}>
                    <div className={cls}>{props.column.name} </div>
                </OverlayTrigger>
        )
    }

    return (
        <div className={cls}>{props.column.name} </div>
    )
}

export {MyCustomHeader};

class TimelineGrid extends React.Component {

    defaultColumns = [
        { key: "StudyDay", name: "Study Day", rawName: "Study Day", sortable: true, width: 100, height: 100, editable: true, headerRenderer: <MyCustomHeader type='studyDay'/> },
        { key: "ScheduleDate", name: "Scheduled Date", rawName: "Scheduled Date", width: 100, height: 100, editable: false, headerRenderer: <MyCustomHeader type='schedDate'/> },
    ];

    headerNameLimit = 40;

    constructor(props) {
        super(props);

        this.state = {
            rows: [],
            lastColIdx: 0,
            lastRowIdx: 0,
            sortColumn: 'StudyDay',
            sortDirection: 'ASC',
            showProcNote: false,
            procNoteName: "",
            procNote: "",
            timelineId: undefined  // Saves the last selected timeline id
        };

        this.state.columns = this.getColumns(props.selectedProject);
    }

    CheckBoxFormatter = (colKey) => {
        return ((props) => {
            if (props.row.RowIdx === 0) {
                return <div onClick={this.handleNoteShow(colKey)}>
                    <i className="fa fa-edit"/>
                </div>
            }
            else {
                return <input type="checkbox" className='chbox' value={props.value} checked={props.value}/>;
            }
        });
    };

    StudyDayFormatter = () => {
        return ((props) => {
            if (props.row.RowIdx === 0) {
                return <div onClick={this.handleNoteShow(colKey)}>
                    <i className="fa fa-edit"/>
                </div>
            }
            else {
                return <input type="checkbox" className='chbox' value={props.value} checked={props.value}/>;
            }
        });
    }

     EmptyRowsView = () => {
        const message = "Select a timeline";
        return (
                <div
                        style={{ textAlign: "center", backgroundColor: "rgb(250, 250, 250)", padding: "100px" }}
                >
                    <h3>{message}</h3>
                </div>
        );
    };

     sortColumns = (cols) => {
         if (!this.props.selectedTimeline || !this.props.selectedTimeline.TimelineProjectItems)
             return cols;

         cols = cols.map(col => {
             this.props.selectedTimeline.TimelineProjectItems.forEach(projItem => {
                 if (col.key === projItem.ProjectItemId) {
                     col.SortOrder = projItem.SortOrder;
                 }
             });
            return col;
         });

         cols.sort((a, b) => {
             if (a.SortOrder == null) return 1;
             if (b.SortOrder == null) return -1;

             return a.SortOrder - b.SortOrder;
         });

         return cols;
     };

    getColumns = (project) => {
        let cols = this.defaultColumns;
        let procCols = [];
        this.state.lastColIdx = 0;

        if (project != null && project.ProjectItems != null && Array.isArray(project.ProjectItems)) {

            procCols = project.ProjectItems.map(col => {
                this.state.lastColIdx++;

                // Limit length of names used in col header
                let formatName = col.description.substring(0, this.headerNameLimit);
                if (col.description.length > this.headerNameLimit) {
                    formatName = formatName.concat('...');
                }

                return {
                    key: col.projectItemId,
                    name: formatName,
                    rawName: col.description,
                    width: 70,
                    height: 100,
                    draggable: true,
                    formatter: this.CheckBoxFormatter(col.projectItemId),
                    headerRenderer: <MyCustomHeader/>
                }
            })
        }

        procCols = this.sortColumns(procCols);

        return cols.concat(procCols);
    };

    // Loads rows from redux state into local react state
    loadRows = () => {
        const timeline = this.props.selectedTimeline;
        let sortedRows = [];

        // If we have already loaded the saved timeline data and timeline items have not changed, don't reload (prevents infinite loop)
        if (timeline != null && timeline.TimelineId === this.state.timelineId) {
            sortedRows = this.state.rows;
        }
        // Loading first time
        else if (timeline == null && typeof this.state.timelineId === "undefined") {
            sortedRows = this.state.rows;
        }
        else { // Reload from saved data

            // First sort columns
            let sortedCols = this.getColumns(this.props.selectedProject);

            let row = [{RowIdx: 0, StudyDay: 'Proc. Note', ScheduleDate: ''}]; // empty row for procedure notes
            let tlRows = [];
            let lastRowIdx = 0;

            if (timeline != null) {

                this.state.timelineId = timeline.TimelineId;
                if (timeline.TimelineItems != null && Array.isArray(timeline.TimelineItems)) {

                    let savedRows;
                    timeline.TimelineItems.forEach(item => {

                        if (item.ProjectItemId === null || item.IsDeleted === true) {
                            return;
                        }

                        // Update row if already exists
                        savedRows = tlRows.filter(savedRow => savedRow.StudyDay === item.StudyDay);
                        if (savedRows.length > 0) {

                            if (!savedRows[0][item.ProjectItemId]) {
                                savedRows[0][item.ProjectItemId] = true;
                                item.RowIdx = savedRows[0].RowIdx;
                            }
                            else {
                                lastRowIdx++;

                                tlRows.push({
                                    RowIdx: lastRowIdx,
                                    StudyDay: item.StudyDay,
                                    ScheduleDate: item.ScheduleDate,
                                    ObjectId: item.ObjectId,
                                    TimelineObjectId: item.TimelineObjectId,
                                    [item.ProjectItemId]: true
                                });

                                item.RowIdx = lastRowIdx;
                            }
                        }
                        // Create new row
                        else {
                            lastRowIdx++;
                            item.RowIdx = lastRowIdx;

                            tlRows.push({
                                RowIdx: lastRowIdx,
                                StudyDay: item.StudyDay,
                                ScheduleDate: item.ScheduleDate,
                                ObjectId: item.ObjectId,
                                TimelineObjectId: item.TimelineObjectId,
                                [item.ProjectItemId]: true
                            });
                        }

                        this.props.onUpdateTimelineItem(item);
                    })
                }
            }

            this.props.onUpdateSelectedTimeline({lastRowIdx: lastRowIdx});

            // Sorts and sets rows in grid state
            let newState = this.sortRows(row.concat(tlRows), this.state.sortColumn, this.state.sortDirection, false);
            sortedRows = newState.rows;

            newState.columns = sortedCols;
            this.setState(Object.assign({}, this.state, newState));
        }

        return sortedRows;
    };

    /* Procedure note handlers */
    handleNoteCancel = () => {
        this.setState({
            showProcNote: false,
            procNoteName: "",
            procNote: ""
        });
    };

    handleNoteShow = (colKey) => {
        return (() => {

                    let procNote = "", procNoteName = "";

                    // Find column
                    for (const column of this.state.columns) {
                        if (column.key === colKey) {

                            // Find timeline project item
                            for (const projItem of this.props.selectedTimeline.TimelineProjectItems) {
                                if (projItem.ProjectItemId === column.key) {
                                    procNote = projItem.TimelineFootNotes;
                                }
                            }
                            procNoteName = column.name;
                            break;
                        }
                    }

                    this.setState({
                        showProcNote: true,
                        procNoteName: procNoteName,
                        procNote: procNote,
                        procNoteColKey: colKey
                    });
                }
        )
    };

    handleNoteSave = () => {
        return ((() => {

            const textArea = this.refs.timelineProcNote;
            if (textArea) {

                let stateCopy = Object.assign({}, this.state);
                let projectItemId;
                for (const column of stateCopy.columns) {

                    if (column.key === this.state.procNoteColKey) {
                        column.procNote = textArea.value;
                        projectItemId = column.key;
                        break;
                    }
                }

                stateCopy.showProcNote = false;
                stateCopy.procNoteName = "";

                this.setState(stateCopy);

                this.props.onUpdateTimelineProjectItem({
                    TimelineFootNotes: textArea.value,
                    ProjectItemId: projectItemId,
                    IsDirty: true
                })
            }

        }).apply(this))
    };

    // Delete row
    getCellActions = (column, row) => {
        let action = {
            icon: <i className="fa fa-times" />,
            callback: () => {
                (() => {
                    this.deleteTimepoint(row.RowIdx);
                }).apply(this);
            }
        };

        return (column.key === "StudyDay" && row.RowIdx !== 0) ? [action] : null;
    };

    deleteTimepoint = (RowIdx) => {
        const filteredRows = this.state.rows.filter(row => row.RowIdx !== RowIdx);

        this.setState(state => {
            state.rows = filteredRows;
            return state;
        })

        this.props.onDeleteTimelineItem({RowIdx: RowIdx});
    };

    // Checkbox cell handler
    onRowClick = (rowIdx, row, column) => {

        // Noop for first row (procedure notes) and study day and date columns
        if (!column || !column.key || rowIdx === 0 || column.idx === 0 || column.idx === 1) {
            return;
        }

        const rowCopy = Object.assign({}, row);

        if (rowCopy[column.key] === undefined || rowCopy[column.key] === '') {
            rowCopy[column.key] = false;
        }

        rowCopy[column.key] = !rowCopy[column.key];

        this.setState(state => {
            let newRows = [];
            for (const oldRow of state.rows) {
                if (oldRow.RowIdx !== rowCopy.RowIdx) {
                    newRows.push(oldRow);
                }
                else {
                    newRows.push(rowCopy);
                }
            }

            state.rows = newRows;
            return state;
        })

        this.props.onAssignTimelineProcedure({
            Value: rowCopy[column.key],
            ProjectItemId: column.key,
            RowIdx: row.RowIdx,
            TimelineObjectId: row.TimelineObjectId,
            ScheduleDate: row.ScheduleDate,
            StudyDay: row.StudyDay
        })

    };

    onGridRowsUpdated = ({ fromRow, toRow, updated }) => {
        let rows = this.state.rows.slice();
        for (let i = fromRow; i <= toRow; i++) {
            rows[i] = { ...rows[i], ...updated };
            this.props.onUpdateTimelineRow(rows[i]);
        }

        const stateCopy = Object.assign({}, this.state, { rows: rows });

        this.setState(stateCopy);
    };

    // Add a row
    onAddClick = () => {
        const stateCopy = Object.assign({}, this.state);
        let RowIdx = this.props.lastRowIdx;
        RowIdx++;

        const newRow = { RowIdx: RowIdx, StudyDay: "", ScheduleDate: null, IsDirty: true, IsDeleted: false };
        this.props.onAddTimelineItem(newRow);

        stateCopy.rows.push(newRow);

        this.setState(stateCopy);

        this.props.onUpdateSelectedTimeline({lastRowIdx: RowIdx});
    };

    // Finish drag and drop of column
    onHeaderDrop = (source, target) => {
        if (!this.props.selectedTimeline || !this.props.selectedTimeline.TimelineProjectItems) {
            return;
        }

        const stateCopy = Object.assign({}, this.state);
        const columnSourceIndex = this.state.columns.findIndex(
                i => i.key === source
        );
        const columnTargetIndex = this.state.columns.findIndex(
                i => i.key === target
        );

        stateCopy.columns.splice(
                columnTargetIndex,
                0,
                stateCopy.columns.splice(columnSourceIndex, 1)[0]
        );

        const emptyColumns = Object.assign({}, this.state, { columns: [] });
        this.setState(emptyColumns);

        const reorderedColumns = Object.assign({}, this.state, {
            columns: stateCopy.columns
        });
        this.setState(reorderedColumns);

        // Save to redux
        if (this.props.selectedTimeline && this.props.selectedTimeline.TimelineProjectItems) {

            const defaultColCount = 2;
            this.props.onUpdateTimelineProjectItem({
                ProjectItemId: source,
                SortOrder: columnTargetIndex - defaultColCount,
                IsDirty: true
            })

            this.props.onUpdateTimelineProjectItem({
                ProjectItemId: target,
                SortOrder: columnSourceIndex - defaultColCount,
                IsDirty: true
            })
        }
    };

    setSort = (sortColumn, sortDirection) => {
        this.sortRows(this.state.rows, sortColumn, sortDirection, true);
    };

    sortRows = (initialRows, sortColumn, sortDirection, setState) => {
        const comparer = (a, b) => {

            // Keep procedure note row on top
            if (a.RowIdx === 0) {
                return -1;
            }
            if (b.RowIdx === 0) {
                return 1;
            }

            let aVal = parseInt(a[sortColumn]);
            let bVal = parseInt(b[sortColumn]);

            if (isNaN(aVal)) {
                return 1;
            }

            if (isNaN(bVal)) {
                return -1;
            }

            if (sortDirection === "ASC" || sortDirection === "NONE") {
                return aVal > bVal ? 1 : -1;
            } else if (sortDirection === "DESC") {
                return aVal < bVal ? 1 : -1;
            }
        };

        const sortedRows = [...initialRows].sort(comparer);
        if (setState) {
            this.setState(Object.assign({}, this.state, {
                rows: sortedRows,
                sortDirection: sortDirection,
                sortColumn: sortColumn
            }));
        }

        return {
            rows: sortedRows,
            sortDirection: sortDirection,
            sortColumn: sortColumn
        };
    };

    render() {
        this.loadRows(this.props.selectedTimeline);

        return (
                <div className='timeline-grid'>
                    <Modal show={this.state.showProcNote} onHide={this.handleNoteCancel}>
                        <Modal.Header closeButton>
                            <Modal.Title>Procedure Note - {this.state.procNoteName}</Modal.Title>
                        </Modal.Header>
                        <Modal.Body>
                            <textarea
                                    ref={'timelineProcNote'}
                                    cols={80} rows={5}
                                    defaultValue={this.state.procNote}
                                    // onChange={}
                            />
                        </Modal.Body>
                        <Modal.Footer>
                            <Button onClick={this.handleNoteSave}>Save</Button>
                            <Button onClick={this.handleNoteCancel}>Cancel</Button>
                        </Modal.Footer>
                    </Modal>
                    <div className='col-sm-12'>
                        <div className='col-sm-2 row input-row'>
                            <Button
                                    className='add-delete-btn'
                                    onClick={this.onAddClick}
                            ><i className='fa fa-plus' /></Button>
                        </div>
                        <div className='col-sm-10' />
                    </div>
                    <div className='col-sm-12'>
                        <DraggableContainer
                                onHeaderDrop={this.onHeaderDrop}
                        >
                            <ReactDataGrid
                                    columns={this.state.columns}
                                    rowGetter={i => this.state.rows[i]}
                                    rowsCount={this.state.rows.length}
                                    onGridRowsUpdated={this.onGridRowsUpdated}
                                    enableCellSelect={true}
                                    getCellActions={this.getCellActions}
                                    minHeight={520}
                                    onGridSort={this.setSort}
                                    onRowClick={this.onRowClick}
                                    emptyRowsView={this.EmptyRowsView}
                            />
                        </DraggableContainer>
                    </div>
                </div>
        );
    }
}

const mapStateToProps = state => ({
    selectedProject: state.project.selectedProject || null,
    selectedTimeline: state.project.selectedTimeline || null,
    lastRowIdx: state.project.selectedTimeline ? (state.project.selectedTimeline.lastRowIdx || 0) : 0
})

const mapDispatchToProps = dispatch => ({
    onAddTimelineItem: timelineItem => dispatch(addTimelineItem(timelineItem)),
    onUpdateTimelineRow: timelineItem => dispatch(updateTimelineRow(timelineItem)),
    onUpdateTimelineItem: timelineItem => dispatch(updateTimelineItem(timelineItem)),
    onUpdateSelectedTimeline: timeline => dispatch(updateSelectedTimeline(timeline)),
    onAssignTimelineProcedure: item => dispatch(assignTimelineProcedure(item)),
    onUpdateTimelineProjectItem: projectItem => dispatch(updateTimelineProjectItem(projectItem)),
    onDeleteTimelineItem: timelineItem => dispatch(deleteTimelineItem(timelineItem))
})

export default connect(
        mapStateToProps,
        mapDispatchToProps
)(TimelineGrid)