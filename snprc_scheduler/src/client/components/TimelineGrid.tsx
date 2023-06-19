import React from 'react';
import { connect } from 'react-redux';
import ReactDataGrid from 'react-data-grid';
import {Button, Modal, OverlayTrigger, Tooltip} from 'react-bootstrap';
import Moment from 'react-moment';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { library } from '@fortawesome/fontawesome-svg-core'
import { faPlus, faPlusCircle } from '@fortawesome/free-solid-svg-icons';
import { faFile, faFileAlt  } from '@fortawesome/free-regular-svg-icons';

import { AppState } from '../reducers';
import DraggableContainer from './dnd/DraggableContainer';
import {
    addTimelineItem,
    assignTimelineProcedure,
    deleteTimelineItem,
    formatDateString,
    getDay0Date,
    setTimelineDayZero,
    showAlertBanner,
    showConfirm,
    updateSelectedTimeline,
    updateStudyDayNote,
    updateTimelineItem,
    updateTimelineProjectItem,
    updateTimelineRow,
} from '../actions/dataActions';

library.add(faPlus);
library.add(faPlusCircle);
library.add(faFileAlt);
library.add(faFile);

function MyCustomHeader(props) {
    let cls = 'procedure-tl-grid-hdr';
    if (props.type === 'studyDay') {
        cls = 'day-tl-grid-hdr';
    }
    else if (props.type === 'schedDate') {
        cls = 'time-tl-grid-hdr';
    }
    else if (props.type === 'schedDay') {
        cls = 'wkDay-t1-grid-hdr';
    }
    else if (props.type === 'studyDayNote') {
        cls = 'studyDayNote-t1-grid-hdr';
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

class TimelineGrid extends React.Component<any, any> {

    headerNameLimit = 40;

    constructor(props) {
        super(props);

        this.state = this.getInitState();
    }

    getInitState = () => {
        return{
            rows: [],
            lastColIdx: 0,
            lastRowIdx: 0,
            sortColumn: 'StudyDay',
            sortMinorColumn: 'RowIdx',
            sortDirection: 'ASC',
            showProcNote: false,
            procNoteName: "",
            procNote: "",
            rowId: undefined,
            revisionNum: undefined,
            day0: ""
        }
    }

    CheckBoxFormatter = (colKey) => {

        return ((props) => {
            const { selectedTimeline } = this.props;
            if (props.row.RowIdx === 0 && selectedTimeline) {
                const projItem = selectedTimeline.TimelineProjectItems.find((item) => item.ProjectItemId === colKey);

                return <div onClick={this.handleNoteShow(colKey)} className={selectedTimeline.IsInUse ? 'timeline-grid-disabled' : ''} >
                    <i><FontAwesomeIcon icon={(projItem && projItem.TimelineFootNotes) ? ["far", "file-alt"] : ["fa", "plus-circle"]}/></i>
                </div>
            }
            else {
                return <input disabled={selectedTimeline.IsInUse} type="checkbox" className='chbox' value={props.value} checked={props.value} onChange={() => {return null}}/>;
            }
        });
    };

    ScheduleDateFormatter = () => {
        return ((props) => {
            if (props.row.RowIdx !== 0 && props.row.ScheduleDate) {
                return <div className={'timeline-grid-disabled'}><Moment format="MM/DD/YYYY" local>{props.row.ScheduleDate}</Moment></div>;
            } else {
                return <div />
            }
        });
    };

    WeekDateFormatter = () => {
        return ((props) => {
            if (props.row.RowIdx !== 0 && props.row.ScheduleDate) {
                return <div className={'timeline-grid-disabled'}><Moment format="ddd" local>{props.row.ScheduleDate}</Moment></div>;
            } else {
                return <div />
            }
        });
    };

    StudyDayNoteFormatter = () => {
        return ((props) => {
            const tooltip = (
                    <Tooltip id="tooltip">
                        {props.row.StudyDayNote ? props.row.StudyDayNote : ''}
                    </Tooltip>
            );

            if (props.row.RowIdx !== 0) {
                return (
                        <OverlayTrigger placement="top" overlay={tooltip}>
                            <div style={{textAlign: 'left'}}>{props.row.StudyDayNote ? props.row.StudyDayNote : ''}</div>
                        </OverlayTrigger>)
            }
            else {
                return <div />
            }
        })
    };

    StudyDayEditable = (rowData) => {
        return rowData.RowIdx !== 0;
    };

    StudyDayNoteEditable = (rowData) => {
        const { selectedTimeline } = this.props;

        // First row and in use timeline not editable
        return !(rowData.RowIdx === 0 || selectedTimeline.IsInUse || rowData.ExtraRow);
    };

    EmptyRowsView = () => {
        return (
            <div style={{textAlign: "center", backgroundColor: "rgb(250, 250, 250)", padding: "100px"}}>
                <h3>Create a new timeline</h3>
            </div>
        );
    };

    defaultColumns = [
        { key: "StudyDay", name: "Study Day", rawName: "Study Day", sortable: true, width: 100, height: 100, editable: this.StudyDayEditable,
            headerRenderer: <MyCustomHeader type='studyDay'/> },
        { key: "ScheduleDate", name: "Scheduled Date", rawName: "Scheduled Date", width: 100, height: 100, editable: false,
            headerRenderer: <MyCustomHeader type='schedDate'/>, formatter: this.ScheduleDateFormatter() },
        { key: "ScheduleDay", name: "Day of the week", rawName: "Day of the week", width: 70, height: 70, editable: false,
            headerRenderer: <MyCustomHeader type='schedDay'/>, formatter: this.WeekDateFormatter() }
    ];

    defaultEndColumns = [
        { key: "StudyDayNote", name: "Study Day Notes", rawName: "Study Day Notes", width: 400, height: 400,
            editable: this.StudyDayNoteEditable, headerRenderer: <MyCustomHeader type='studyDayNote'/>, formatter: this.StudyDayNoteFormatter() },
    ]

    getStudyDay0 = (): string => {
        const { selectedTimeline } = this.props;

        if ( selectedTimeline?.TimelineItems?.length > 0 && selectedTimeline.TimelineItems[0].ScheduleDate) {
            const date = new Date(selectedTimeline.TimelineItems[0].ScheduleDate);
            return getDay0Date(formatDateString(date), parseInt(selectedTimeline.TimelineItems[0].StudyDay));
        }

        return '';
    };

    sortColumns = (cols) => {
         if (!this.props.selectedTimeline || !this.props.selectedTimeline.TimelineProjectItems) {
             return cols;
         }

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

        if (project != null && project.ProjectItems != null && Array.isArray(project.ProjectItems)) {

            procCols = project.ProjectItems.map(col => {

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

        return cols.concat(procCols).concat(this.defaultEndColumns);
    };

    updateScheduledDate = () => {
        const { selectedTimeline } = this.props;

        if (selectedTimeline && selectedTimeline.forceReload) {

            let newRows = this.state.rows.map(row => {
                let newRow = Object.assign({}, row);
                let found = this.props.selectedTimeline.TimelineItems.find(item => row.RowIdx === item.RowIdx);
                if (found) {
                    newRow.ScheduleDate = found.ScheduleDate;
                }
                return newRow;
            })

            this.setState(Object.assign({}, this.state, {
                rows: newRows
            }));

            this.props.selectedTimeline.forceReload = false;
        }
    };

    loadStudyDayNotes = (rows, dirty) => {
        const {selectedTimeline, onUpdateStudyDayNote} = this.props;

        if (selectedTimeline.StudyDayNotes != null && Array.isArray(selectedTimeline.StudyDayNotes)) {

            // Timeline rows should already be created just need to populate study day notes
            let savedRows;
            selectedTimeline.StudyDayNotes.forEach(note => {

                savedRows = rows.filter(savedRow => savedRow.StudyDay === note.StudyDay);
                if (savedRows.length > 0) {
                    savedRows[0].StudyDayNote = note.StudyDayNote;
                    note.RowIdx = savedRows[0].RowIdx;
                }

                onUpdateStudyDayNote(note, dirty);
            })
        }
    };

    // Loads rows from redux state into local react state
    loadRows = (dirty) => {
        const {selectedTimeline, selectedProject, onUpdateTimelineItem, onUpdateSelectedTimeline} = this.props;
        const {rows, rowId, revisionNum, sortColumn, sortMinorColumn, sortDirection} = this.state;
        let allRows = [];

        // If we have already loaded the saved timeline data, don't reload (prevents infinite loop)
        if (selectedTimeline != null && selectedTimeline.RowId === rowId && selectedTimeline.RevisionNum === revisionNum && !selectedTimeline.forceRowRecalc) {
            allRows = rows;
        }
        // Loading first time
        else if (selectedTimeline == null && typeof rowId === "undefined") {
            allRows = rows;
        }
        // local state needs to be reset (all timelines for selected project have been deleted)
        else if (selectedTimeline == null && typeof rowId !== "undefined") {
            this.setState(this.getInitState());
        }
        else { // Reload from saved data

            let day0 = this.getStudyDay0();
            if (day0) {
                this.props.onUpdateTimelineDayZero(day0, false, false);
            }

            // First sort columns
            let sortedCols = this.getColumns(selectedProject);

            let row = []; // empty row for procedure notes
            let tlRows = [];
            let lastRowIdx = 0;

            if (selectedTimeline != null && selectedTimeline.Description) {

                this.state.rowId = selectedTimeline.RowId;
                this.state.revisionNum = selectedTimeline.RevisionNum;
                if (selectedTimeline.TimelineItems != null && Array.isArray(selectedTimeline.TimelineItems)) {

                    row = [{RowIdx: 0, StudyDay: '', ScheduleDate: ''}]; // empty row for procedure notes

                    let savedRows;
                    selectedTimeline.TimelineItems.forEach(item => {

                        if (item.IsDeleted === true) {
                            return;
                        }

                        // Update row if already exists
                        savedRows = tlRows.filter(savedRow => savedRow.StudyDay === item.StudyDay);
                        if (savedRows.length > 0) {

                            if (item.ProjectItemId && !savedRows[0][item.ProjectItemId]) {
                                savedRows[0][item.ProjectItemId] = true;
                                item.RowIdx = savedRows[0].RowIdx;
                            }
                            else {
                                lastRowIdx++;

                                let row = {
                                    RowIdx: lastRowIdx,
                                    StudyDay: item.StudyDay,
                                    ScheduleDate: item.ScheduleDate,
                                    ObjectId: item.ObjectId,
                                    ExtraRow: true,
                                    TimelineObjectId: item.TimelineObjectId
                                };

                                if (item.ProjectItemId) {
                                    row[item.ProjectItemId] = true;
                                }

                                tlRows.push(row);
                                item.RowIdx = lastRowIdx;
                            }
                        }
                        // Create new row
                        else {
                            lastRowIdx++;
                            item.RowIdx = lastRowIdx;

                            let newRow = {
                                RowIdx: lastRowIdx,
                                StudyDay: item.StudyDay,
                                ScheduleDate: item.ScheduleDate,
                                ObjectId: item.ObjectId,
                                TimelineObjectId: item.TimelineObjectId
                            };

                            if (item.ProjectItemId) {
                                newRow[item.ProjectItemId] = true;
                            }

                            tlRows.push(newRow);
                        }

                        onUpdateTimelineItem(item, dirty);
                    })
                }

                this.loadStudyDayNotes(tlRows, dirty);
            }
            onUpdateSelectedTimeline({lastRowIdx: lastRowIdx, forceRowRecalc: false}, dirty);

            // Sorts and sets rows in grid state
            let newState = this.sortRows(row.concat(tlRows), sortColumn, sortMinorColumn, sortDirection, false);
            allRows = newState.rows;

            newState.columns = sortedCols;
            this.setState(Object.assign({}, this.state, newState));
        }

        return allRows;
    };

    /* Procedure note handlers */
    handleNoteCancel = (): void => {
        this.setState({ showProcNote: false, procNoteName: '', procNote: '' });
    };

    handleNoteShow = (colKey) => {
        return (() => {
                    const {selectedTimeline} = this.props;

                    if (!selectedTimeline.IsInUse) {

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
                }
        )
    };

    handleNoteSave = () => {
        const textArea: any = this.refs.timelineProcNote;
        if (textArea) {
            let stateCopy: any = Object.assign({}, this.state);
            let projectItemId;
            for (const column of stateCopy.columns) {

                if (column.key === this.state.procNoteColKey) {
                    column.procNote = textArea.value;
                    projectItemId = column.key;
                    break;
                }
            }

            const newRows = this.state.rows.map((row, index) => {
                if (index === 0) {
                    row = Object.assign({}, row);
                }
                return row;
            });

            stateCopy.showProcNote = false;
            stateCopy.procNoteName = '';
            stateCopy.rows = newRows;

            this.setState(stateCopy);

            this.props.onUpdateTimelineProjectItem({
                TimelineFootNotes: textArea.value,
                ProjectItemId: projectItemId,
                IsDirty: true,
            })
        }
    };

    // Delete row
    getCellActions = (column, row) => {
        const { selectedTimeline } = this.props;

        let action = {
            icon: <i className={"fa fa-times timeline-grid-delete-icon " + (selectedTimeline && selectedTimeline.IsInUse ? 'timeline-grid-disabled' : '')} />,
            callback: () => {
                (() => {
                    this.deleteTimepoint(row.RowIdx);
                }).apply(this);
            }
        };

        return (column.key === "StudyDay" && row.RowIdx !== 0) ? [action] : null;
    };

    deleteTimepoint = (RowIdx) => {
        const { selectedTimeline } = this.props;
        if (!selectedTimeline.IsInUse) {
            const filteredRows = this.state.rows.filter(row => row.RowIdx !== RowIdx);

            this.setState(state => {
                state.rows = filteredRows;
                return state;
            });

            this.props.onDeleteTimelineItem({RowIdx: RowIdx});
        }
    };

    // Checkbox cell handler
    onRowClick = (rowIdx, row, column) => {

        const { selectedTimeline } = this.props;

        // Noop for first row (procedure notes) and study day and date columns
        if (!column || !column.key || rowIdx === 0 ||
                column.idx === 0 || column.idx === 1 || column.idx === 2 || column.key === 'StudyDayNote' ||
                selectedTimeline.IsInUse) {
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
            StudyDay: row.StudyDay,
            StudyDayNote: row.StudyDayNote
        })
    };

    onGridRowsUpdated = ({fromRow, toRow, updated}) => {
        const { selectedTimeline } = this.props;
        let rows = this.state.rows.slice();

        for (let i = fromRow; i <= toRow; i++) {
            rows[i] = {...rows[i], ...updated};
            this.props.onUpdateTimelineRow(rows[i]);
        }

        if (updated.StudyDay && selectedTimeline.StudyDay0) {
            this.props.onUpdateTimelineDayZero(selectedTimeline.StudyDay0, true, true);
        }

        const stateCopy = {rows: [...rows]};
        this.setState(stateCopy);
    };

    getTooltip = (label) => {
        return (<Tooltip id="tooltip">
            {label}
        </Tooltip>)
    }

    // Add a row
    onAddClick = () => {
        const { selectedTimeline } = this.props;

        if (selectedTimeline && selectedTimeline.Description && !selectedTimeline.IsInUse) {
            const stateCopy = Object.assign({}, this.state);
            let RowIdx = this.props.lastRowIdx;
            RowIdx++;

            const newRow = {RowIdx: RowIdx, StudyDay: "", ScheduleDate: null, IsDirty: true, IsDeleted: false,
                StudyDayNote: '', TimelineObjectId: selectedTimeline.ObjectId};
            this.props.onAddTimelineItem(newRow);

            stateCopy.rows.push(newRow);

            this.setState(stateCopy);

            this.props.onUpdateSelectedTimeline({lastRowIdx: RowIdx}, true);
        }
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

    sortRows = (initialRows, sortColumn, sortMinorColumn, sortDirection, setState?) => {
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

            if (aVal === bVal) {
                let aMinor = parseInt(a[sortMinorColumn]);
                let bMinor = parseInt(b[sortMinorColumn]);

                if (isNaN(aMinor)) {
                    return 1;
                }

                if (isNaN(bMinor)) {
                    return -1;
                }

                if (sortDirection === "ASC" || sortDirection === "NONE") {
                    return aMinor > bMinor ? 1 : -1;
                } else if (sortDirection === "DESC") {
                    return aMinor < bMinor ? 1 : -1;
                }
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

    componentDidMount(): void {
        this.loadRows(false);
    }

    componentDidUpdate(): void {
        this.loadRows(false);
        this.updateScheduledDate();
    }

    render() {
        const { showProcNote, procNoteName, procNote, columns, rows } = this.state;
        const { selectedTimeline } = this.props;

        return (
            <div className="timeline-grid">
                <Modal show={showProcNote} onHide={this.handleNoteCancel}>
                    <Modal.Header closeButton>
                        <Modal.Title>Procedure Note - {procNoteName}</Modal.Title>
                    </Modal.Header>
                    <Modal.Body>
                            <textarea
                                className="timeline-grid-proc-note"
                                defaultValue={procNote}
                                ref="timelineProcNote"
                            />
                    </Modal.Body>
                    <Modal.Footer>
                        <Button onClick={this.handleNoteSave}>Save</Button>
                        <Button onClick={this.handleNoteCancel}>Cancel</Button>
                    </Modal.Footer>
                </Modal>
                <div className='col-sm-12 zero-side-padding'>
                    <div className='col-sm-2 row input-row'>
                        <OverlayTrigger placement="top" overlay={this.getTooltip("New timeline study day")}>
                            <Button
                                className="add-delete-btn"
                                onClick={this.onAddClick}
                                disabled={!selectedTimeline || selectedTimeline.IsInUse}
                            >
                                <FontAwesomeIcon icon="plus" />
                            </Button>
                        </OverlayTrigger>
                    </div>
                    <div className='col-sm-10' />
                </div>
                <div className='col-sm-12 zero-side-padding'>
                    <DraggableContainer onHeaderDrop={this.onHeaderDrop}>
                        <ReactDataGrid
                            columns={columns}
                            rowGetter={i => rows[i]}
                            rowsCount={rows.length}
                            onGridRowsUpdated={this.onGridRowsUpdated}
                            enableCellSelect={true}
                            getCellActions={this.getCellActions}
                            minHeight={445}
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

const mapStateToProps = (state: AppState) => ({
    selectedProject: state.project.selectedProject || null,
    selectedTimeline: state.timeline.selectedTimeline || null,
    lastRowIdx: state.timeline.selectedTimeline ? (state.timeline.selectedTimeline.lastRowIdx || 0) : 0,
})

const mapDispatchToProps = dispatch => ({
    onAddTimelineItem: timelineItem => dispatch(addTimelineItem(timelineItem)),
    onUpdateTimelineRow: timelineItem => dispatch(updateTimelineRow(timelineItem)),
    onUpdateTimelineItem: (timelineItem, dirty) => dispatch(updateTimelineItem(timelineItem, dirty)),
    onUpdateStudyDayNote: (timelineItem, dirty) => dispatch(updateStudyDayNote(timelineItem, dirty)),
    onUpdateSelectedTimeline: (timeline, dirty) => dispatch(updateSelectedTimeline(timeline, dirty)),
    onAssignTimelineProcedure: item => dispatch(assignTimelineProcedure(item)),
    onUpdateTimelineProjectItem: projectItem => dispatch(updateTimelineProjectItem(projectItem)),
    onDeleteTimelineItem: timelineItem => dispatch(deleteTimelineItem(timelineItem)),
    onUpdateTimelineDayZero: (day0, forceReload, dirty) => dispatch(setTimelineDayZero(day0, forceReload, dirty)),
    showAlertBanner: timeline => dispatch(showAlertBanner(timeline)),
    showConfirm: confirm => dispatch(showConfirm(confirm)),
})

export default connect(mapStateToProps, mapDispatchToProps)(TimelineGrid);
