import React from "react";
import ReactDataGrid from "react-data-grid";
import {Button, Modal, OverlayTrigger, Tooltip} from "react-bootstrap";
import DraggableContainer from "./dnd/DraggableContainer";
import PropTypes from "prop-types";
import {selectTimeline} from "../actions/dataActions";
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
        { key: "timepoint", name: "Study Day", rawName: "Study Day", sortable: true, width: 100, height: 100, editable: true, headerRenderer: <MyCustomHeader type='studyDay'/> },
        { key: "scheduleDate", name: "Scheduled Date", rawName: "Scheduled Date", width: 100, height: 100, editable: false, headerRenderer: <MyCustomHeader type='schedDate'/> },
    ];

    headerNameLimit = 40;

    constructor(props) {
        super(props);

        this.state = {
            rows: [],
            lastColIdx: 0,
            lastRowIdx: 0,
            sortColumn: 'timepoint',
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
            if (props.row.idx === 0) {
                return <div onClick={this.handleNoteShow(colKey)}>
                    <i className="fa fa-edit"/>
                </div>
            }
            else {
                return <input type="checkbox" className='chbox' value={props.value} checked={props.value}/>;
            }
        });
    };

     EmptyRowsView = () => {
        const message = "Select a timeline";
        return (
                <div
                        style={{ textAlign: "center", backgroundColor: "#e8e8e8", padding: "100px" }}
                >
                    {/*<img src="./logo.png" alt={message} />*/}
                    <h3>{message}</h3>
                </div>
        );
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

        return cols.concat(procCols);
    };

    // Loads rows from redux state into local react state
    updateRows = () => {
        const timeline = this.props.selectedTimeline;
        let sortedRows = [];

        // If we have already loaded the saved timeline data, don't reload (prevents infinite loop)
        if (timeline != null && timeline.TimelineId === this.state.timelineId) {
            return this.state.rows;
        }
        // Loading first time
        else if (timeline == null && typeof this.state.timelineId === "undefined") {
            return this.state.rows;
        }
        else { // Reload from saved data
            let row = [{idx: 0}]; // empty row for procedure notes
            let tlRows = [];
            this.state.lastRowIdx = 0;

            if (timeline != null) {

                this.state.timelineId = timeline.TimelineId;
                if (timeline.TimelineItems != null && Array.isArray(timeline.TimelineItems)) {

                    tlRows = timeline.TimelineItems.map(row => {
                        this.state.lastRowIdx++;

                        return {
                            idx: this.state.lastRowIdx,
                            timepoint: row.StudyDay,
                            scheduleDate: row.ScheduleDate,
                            [row.ProjectItemId]: true
                        }
                    })
                }
            }

            // Sorts and sets rows in grid state
            sortedRows = this.sortRows(row.concat(tlRows), this.state.sortColumn, this.state.sortDirection);
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
                    for (const column of this.state.columns) {
                        if (column.key === colKey) {
                            procNote = column.procNote;
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
                for (const column of stateCopy.columns) {

                    if (column.key === this.state.procNoteColKey) {
                        column.procNote = textArea.value;
                        break;
                    }
                }

                stateCopy.showProcNote = false;
                stateCopy.procNoteName = "";

                this.setState(stateCopy);
            }

        }).apply(this))
    };

    // Delete row
    getCellActions = (column, row) => {
        let action = {
            icon: <i className="fa fa-times" />,
            callback: () => {
                (() => {
                    this.deleteTimepoint(row.idx);
                }).apply(this);
            }
        };

        return (column.key === "timepoint" && row.idx !== 0) ? [action] : null;
    };

    deleteTimepoint = (idx) => {
        const filteredRows = this.state.rows.filter(row => row.idx !== idx);

        this.setState(state => {
            state.rows = filteredRows;
            return state;
        })
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
                if (oldRow.idx !== rowCopy.idx) {
                    newRows.push(oldRow);
                }
                else {
                    newRows.push(rowCopy);
                }
            }

            state.rows = newRows;
            return state;
        })

    };

    onGridRowsUpdated = ({ fromRow, toRow, updated }) => {
        this.setState(state => {
            const rows = state.rows.slice();
            for (let i = fromRow; i <= toRow; i++) {
                rows[i] = { ...rows[i], ...updated };
            }
            return { rows };
        });
    };

    // Add a row
    onAddClick = () => {
        const stateCopy = Object.assign({}, this.state);
        let idx = this.state.lastRowIdx;
        idx++;

        stateCopy.lastRowIdx = idx;
        stateCopy.rows.push(
                    { idx: idx, timepoint: "", scheduleDate: "" }
            );

        this.setState(stateCopy);
    };

    // Finish drag and drop of column
    onHeaderDrop = (source, target) => {
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
    };

    setSort = (sortColumn, sortDirection) => {
        this.sortRows(this.state.rows, sortColumn, sortDirection);
    };

    sortRows = (initialRows, sortColumn, sortDirection) => {
        const comparer = (a, b) => {

            // Keep procedure note row on top
            if (a.idx === 0) {
                return -1;
            }
            if (b.idx === 0) {
                return 1;
            }

            let aVal = parseInt(a[sortColumn]);
            let bVal = parseInt(b[sortColumn]);

            if (isNaN(aVal)) {
                return -1;
            }

            if (isNaN(bVal)) {
                return 1;
            }

            if (sortDirection === "ASC" || sortDirection === "NONE") {
                return aVal > bVal ? 1 : -1;
            } else if (sortDirection === "DESC") {
                return aVal < bVal ? 1 : -1;
            }
        };

        const sortedRows = [...initialRows].sort(comparer);
        this.setState(Object.assign({}, this.state, {
            rows: sortedRows,
            sortDirection: sortDirection,
            sortColumn: sortColumn
        }));

        return sortedRows;
    };

    render() {
        this.updateRows(this.props.selectedTimeline);

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
    selectedTimeline: state.project.selectedTimeline || null
})

export default connect(
        mapStateToProps
)(TimelineGrid)