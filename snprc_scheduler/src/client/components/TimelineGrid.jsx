import React from "react";
import { DataGrid, renderTextEditor } from "react-data-grid";
import { Button, Modal, OverlayTrigger, Tooltip } from "react-bootstrap";
import { DraggableContainer } from "./dnd/DraggableContainer";
import Moment from 'react-moment';
import {
    addTimelineItem,
    assignTimelineProcedure,
    deleteTimelineItem,
    formatDateString,
    getDay0Date,
    setTimelineDayZero,
    updateSelectedTimeline,
    updateStudyDayNote,
    updateTimelineItem,
    updateTimelineProjectItem,
    updateTimelineRow
} from "../actions/dataActions";
import { connect } from "react-redux";

import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { library } from '@fortawesome/fontawesome-svg-core'
import { faPlus, faPlusCircle } from '@fortawesome/free-solid-svg-icons';
import { faFile, faFileAlt  } from '@fortawesome/free-regular-svg-icons';

library.add(faPlus);
library.add(faPlusCircle);
library.add(faFileAlt);
library.add(faFile);

// Flag to enable/disable the feature that disables rows outside the timeline date range
// Set to true to enable disabled rows, false to disable this feature
const ENABLE_OUT_OF_RANGE_ROW_DISABLE = true;

function MyCustomHeader(props) {
    const tooltip = (
            <Tooltip id="tooltip">
                {props.column.rawName}
            </Tooltip>
    );

    return (
            <OverlayTrigger placement="top" overlay={tooltip}>
                <div className={'procedure-tl-grid-hdr'}>{props.column.name} </div>
            </OverlayTrigger>
    )
}

export { MyCustomHeader };

class TimelineGrid extends React.Component {

    headerNameLimit = 40;

    constructor(props) {
        super(props);

        this.timelineProcNoteRef = React.createRef();
        this.dataGridRef = React.createRef();
        this.state = this.getInitState();
        this.state.columns = this.getColumns(props.selectedProject);
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
            day0: "",
            key: 0
        }
    }

    getGridKey = () => {
        return Math.random();
    };

    isScheduleDateWithinRange = (row) => {
        // If the feature is disabled, all rows are considered within range
        if (!ENABLE_OUT_OF_RANGE_ROW_DISABLE) {
            return true;
        }

        const { selectedTimeline } = this.props;

        // First row (header) is always considered within range
        if (row.RowIdx === 0) {
            return true;
        }

        // If no schedule date, consider it within range
        if (!row.ScheduleDate) {
            return true;
        }

        // If no timeline or no start/end dates, consider it within range
        if (!selectedTimeline || (!selectedTimeline.StartDate && !selectedTimeline.EndDate)) {
            return true;
        }

        // Strip time from ScheduleDate before converting to a date. This is kind of a hack but we're storing
        // timeline start and end dates as date type and scheduled date as datetime, which causes different timezone
        // corrections in Date conversion.
        const scheduleDateStr = row.ScheduleDate.toString().split(' ')[0];
        const scheduleDate = new Date(scheduleDateStr);
        
        if (selectedTimeline.StartDate) {
            const startDate = new Date(selectedTimeline.StartDate);
            if (scheduleDate < startDate) {
                return false;
            }
        }

        if (selectedTimeline.EndDate) {
            const endDate = new Date(selectedTimeline.EndDate);
            if (scheduleDate > endDate) {
                return false;
            }
        }

        return true;
    };

    CheckBoxFormatter = (colKey) => {

        return ((props) => {
            const { selectedTimeline } = this.props;
            if (!selectedTimeline) {
                return <div />;
            }
            if (props.row.RowIdx === 0 && selectedTimeline) {
                const projItem = selectedTimeline.TimelineProjectItems.find((item) => item.ProjectItemId === colKey);

                return <div onClick={this.handleNoteShow(colKey)} className={selectedTimeline.IsInUse ? 'timeline-grid-disabled' : ''} >
                    <i><FontAwesomeIcon icon={(projItem && projItem.TimelineFootNotes) ? faFileAlt : faPlusCircle}/></i>
                </div>
            }
            else {
                const isOutOfRange = !this.isScheduleDateWithinRange(props.row);
                const checkboxInput = <input disabled={selectedTimeline.IsInUse || isOutOfRange} type="checkbox" className='chbox' value={props.row[colKey] || false} checked={props.row[colKey] || false} onChange={() => {return null}}/>;
                
                if (isOutOfRange) {
                    const disabledTooltip = (
                        <Tooltip id="disabled-tooltip">
                            Study day outside of revision start and end date
                        </Tooltip>
                    );
                    return (
                        <OverlayTrigger placement="top" overlay={disabledTooltip}>
                            <span>{checkboxInput}</span>
                        </OverlayTrigger>
                    );
                }
                return checkboxInput;
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

    StudyDayNoteFormatter = (props) => {
        const isOutOfRange = !this.isScheduleDateWithinRange(props.row);
        
        const tooltip = isOutOfRange ? (
                <Tooltip id="disabled-tooltip">
                    Study day outside of revision start and end date
                </Tooltip>
        ) : (
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
    };

    StudyDayNoteEditable = (rowData) => {
        const { selectedTimeline } = this.props;

        // First row, in use timeline, extra row, or out of date range not editable
        const isOutOfRange = !this.isScheduleDateWithinRange(rowData);
        return !(rowData.RowIdx === 0 || !selectedTimeline || selectedTimeline.IsInUse || rowData.ExtraRow || isOutOfRange);

    };

    StudyDayEditable = (rowData) => {
        const isOutOfRange = !this.isScheduleDateWithinRange(rowData);
        // If row has no TimelineItemId, allow editing even if out of range
        const hasNoTimelineItemId = !rowData.TimelineItemId;
        return rowData.RowIdx !== 0 && (!isOutOfRange || hasNoTimelineItemId);

    };

    StudyDayEditor = ({ row, column, onRowChange, onClose }) => {
        return (
            <input
                    type="number"
                    step="1"
                    pattern="[0-9]*"
                    className="rdg-text-editor"
                    autoFocus
                    value={row[column.key] || ''}
                    onChange={(e) => onRowChange({ ...row, [column.key]: e.target.value })}
                    onBlur={onClose}
            />
        );
    };

    // Render StudyDay cell with delete action
    StudyDayRenderer = (props) => {
        const { row, column } = props;
        const { selectedTimeline } = this.props;
        const isOutOfRange = !this.isScheduleDateWithinRange(row);
        const isInUse = selectedTimeline && selectedTimeline.IsInUse;
        // If row has no TimelineItemId, allow delete even if out of range
        const hasNoTimelineItemId = !row.TimelineItemId;
        const showDeleteIcon = row.RowIdx !== 0 && (!isOutOfRange || hasNoTimelineItemId);

        const cellContent = (
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', width: '100%', height: '100%' }}>
                    <span>{row[column.key]}</span>
                    {showDeleteIcon && (
                            <i
                                    className={"fa fa-times timeline-grid-delete-icon " + (isInUse ? 'timeline-grid-disabled' : '')}
                                    onClick={() => {
                                        if (!isInUse) {
                                            this.deleteTimepoint(row.RowIdx);
                                        }
                                    }}
                                    style={{ cursor: isInUse ? 'not-allowed' : 'pointer' }}
                            />
                    )}
                </div>
        );

        // Only show tooltip for out of range rows that have a TimelineItemId
        if (isOutOfRange && row.RowIdx !== 0 && !hasNoTimelineItemId) {
            const disabledTooltip = (
                <Tooltip id="disabled-tooltip">
                    Study day outside of revision start and end date
                </Tooltip>
            );
            return (
                <OverlayTrigger placement="top" overlay={disabledTooltip}>
                    {cellContent}
                </OverlayTrigger>
            );
        }

        return cellContent;
    };

    EmptyRowsView = () => {
        return (
                <div
                        style={{textAlign: "center", backgroundColor: "rgb(250, 250, 250)", padding: "100px"}}
                >
                    <h3>No timeline data available</h3>
                </div>
        );
    };

    // Returns 'timeline-cell-disabled' for out-of-range rows without TimelineItemId (partially disabled rows)
    getCellDisabledClass = (row) => {
        const isOutOfRange = !this.isScheduleDateWithinRange(row);
        const hasNoTimelineItemId = !row.TimelineItemId;
        // Apply disabled styling to cells in out-of-range rows that have no TimelineItemId
        if (isOutOfRange && hasNoTimelineItemId && row.RowIdx !== 0) {
            return 'timeline-cell-disabled';
        }
        return undefined;
    };

    getDefaultColumns = () => {
        return [
            { key: "StudyDay", name: "Study Day", rawName: "Study Day", sortable: true, width: 100, height: 100, editable: this.StudyDayEditable,
                renderHeaderCell: (props) => <MyCustomHeader type='studyDay' {...props} />,
                renderEditCell: this.StudyDayEditor,
                renderCell: this.StudyDayRenderer
            },
            { key: "ScheduleDate", name: "Scheduled Date", rawName: "Scheduled Date", width: 100, height: 100, editable: false,
                renderHeaderCell: (props) => <MyCustomHeader type='schedDate' {...props} />, renderCell: this.ScheduleDateFormatter(),
                cellClass: (row) => this.getCellDisabledClass(row) },
            { key: "ScheduleDay", name: "Day of the week", rawName: "Day of the week", width: 70, height: 70, editable: false,
                renderHeaderCell: (props) => <MyCustomHeader type='schedDay' {...props} />, renderCell: this.WeekDateFormatter(),
                cellClass: (row) => this.getCellDisabledClass(row) }
        ];
    }

    getDefaultEndColumns = () => {
        return [
            { key: "StudyDayNote", name: "Study Day Notes", rawName: "Study Day Notes", width: 400, height: 400,
                editable: this.StudyDayNoteEditable, renderHeaderCell: (props) => <MyCustomHeader type='studyDayNote' {...props} />,
                // renderCell: this.StudyDayNoteEditor,
                renderCell: this.StudyDayNoteFormatter,
                renderEditCell: renderTextEditor,
                cellClass: (row) => {
                    const disabledClass = this.getCellDisabledClass(row);
                    return disabledClass ? `studyDayNote-cell ${disabledClass}` : 'studyDayNote-cell';
                }
            },
        ];
    }

    getStudyDay0 = () => {
        const { selectedTimeline } = this.props;

        if (selectedTimeline && selectedTimeline.TimelineItems && selectedTimeline.TimelineItems.length > 0
                && selectedTimeline.TimelineItems[0].ScheduleDate) {
            const date = new Date(selectedTimeline.TimelineItems[0].ScheduleDate);
            return getDay0Date(formatDateString(date), parseInt(selectedTimeline.TimelineItems[0].StudyDay));
        }

        return "";
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
        let cols = this.getDefaultColumns();
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
                    renderCell: this.CheckBoxFormatter(col.projectItemId),
                    renderHeaderCell: (props) => <MyCustomHeader {...props} />,
                    cellClass: (row) => this.getCellDisabledClass(row)
                }
            })
        }

        procCols = this.sortColumns(procCols);

        return cols.concat(procCols).concat(this.getDefaultEndColumns());
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
        const { selectedTimeline, onUpdateStudyDayNote } = this.props;

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
        const { selectedTimeline, selectedProject, onUpdateTimelineItem, onUpdateSelectedTimeline, onUpdateTimelineDayZero } = this.props;
        const { rows, rowId, revisionNum, sortColumn, sortMinorColumn, sortDirection } = this.state;
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
                onUpdateTimelineDayZero(day0, false, false);
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
                                    TimelineObjectId: item.TimelineObjectId,
                                    TimelineItemId: item.TimelineItemId
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
                                TimelineObjectId: item.TimelineObjectId,
                                TimelineItemId: item.TimelineItemId
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
            newState.key = this.getGridKey();
            this.setState(Object.assign({}, this.state, newState));
        }

        return allRows;
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
                    const {selectedTimeline} = this.props;

                    if (selectedTimeline && !selectedTimeline.IsInUse) {

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
        return ((() => {

            const textArea = this.timelineProcNoteRef.current;
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

                const newRows = this.state.rows.map((row, index) => {
                    if (index === 0) {
                        row = Object.assign({}, row);
                    }
                    return row;
                });

                stateCopy.showProcNote = false;
                stateCopy.procNoteName = "";
                stateCopy.rows = newRows;

                this.setState(stateCopy);

                this.props.onUpdateTimelineProjectItem({
                    TimelineFootNotes: textArea.value,
                    ProjectItemId: projectItemId,
                    IsDirty: true
                })
            }

        }).apply(this))
    };

    deleteTimepoint = (RowIdx) => {
        const { selectedTimeline, onDeleteTimelineItem } = this.props;
        if (selectedTimeline && !selectedTimeline.IsInUse) {
            const filteredRows = this.state.rows.filter(row => row.RowIdx !== RowIdx);

            this.setState(state => ({
                ...state,
                rows: filteredRows
            }));

            onDeleteTimelineItem({RowIdx: RowIdx});
        }
    };

    // Checkbox cell handler
    onCellClick = (args, event) => {
        const { row, column } = args;
        const { selectedTimeline, onAssignTimelineProcedure } = this.props;

        // Get the row index by finding it in the rows array
        const rowIdx = this.state.rows.findIndex(r => r.RowIdx === row.RowIdx);

        // Noop for first row (procedure notes) and study day and date columns
        if (!column || !column.key || rowIdx === 0 ||
                column.key === 'StudyDay' || column.key === 'ScheduleDate' || column.key === 'ScheduleDay' || column.key === 'StudyDayNote' ||
                !selectedTimeline || selectedTimeline.IsInUse) {
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
        });

        onAssignTimelineProcedure({
            Value: rowCopy[column.key],
            ProjectItemId: column.key,
            RowIdx: row.RowIdx,
            TimelineObjectId: row.TimelineObjectId,
            ScheduleDate: row.ScheduleDate,
            StudyDay: row.StudyDay,
            StudyDayNote: row.StudyDayNote
        })
    };

    onRowsChange = (rows, data) => {
        const { selectedTimeline, onUpdateTimelineRow, onUpdateTimelineDayZero } = this.props;
        const { indexes } = data;

        const rowIndex = indexes[0];
        const updatedRow = rows[rowIndex];
        onUpdateTimelineRow({...updatedRow});

        if (updatedRow.StudyDay && selectedTimeline.StudyDay0) {
            onUpdateTimelineDayZero(selectedTimeline.StudyDay0, true, true);
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
        const { selectedTimeline, onUpdateSelectedTimeline, onAddTimelineItem, lastRowIdx } = this.props;

        if (selectedTimeline && selectedTimeline.Description && !selectedTimeline.IsInUse) {
            let RowIdx = lastRowIdx;
            RowIdx++;

            const newRow = {RowIdx: RowIdx, StudyDay: "", ScheduleDate: null, IsDirty: true, IsDeleted: false,
                StudyDayNote: '', TimelineObjectId: selectedTimeline.ObjectId};
            onAddTimelineItem(newRow);

            const newRows = [...this.state.rows, newRow];

            this.setState({ ...this.state, rows: newRows }, () => {
                // Focus on the new row's first cell (StudyDay column at index 0)
                if (this.dataGridRef.current) {
                    const newRowIdx = this.state.rows.length - 1;
                    this.dataGridRef.current.selectCell({ idx: 0, rowIdx: newRowIdx }, { enableEditor: true });
                }
            });

            onUpdateSelectedTimeline({lastRowIdx: RowIdx}, true);
        }
    };

    // Finish drag and drop of column
    onHeaderDrop = (source, target) => {
        const { selectedTimeline, onUpdateTimelineProjectItem } = this.props;
        const { columns } = this.state;

        if (!selectedTimeline || !selectedTimeline.TimelineProjectItems) {
            return;
        }

        const stateCopy = Object.assign({}, this.state);
        const columnSourceIndex = columns.findIndex(
                i => i.key === source
        );
        const columnTargetIndex = columns.findIndex(
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
            columns: stateCopy.columns,
            key: this.getGridKey()
        });
        this.setState(reorderedColumns);

        // Save to redux
        if (selectedTimeline && selectedTimeline.TimelineProjectItems) {

            const defaultColCount = 2;
            onUpdateTimelineProjectItem({
                ProjectItemId: source,
                SortOrder: columnTargetIndex - defaultColCount,
                IsDirty: true
            })

            onUpdateTimelineProjectItem({
                ProjectItemId: target,
                SortOrder: columnSourceIndex - defaultColCount,
                IsDirty: true
            })
        }
    };

    sortRows = (initialRows, sortColumn, sortMinorColumn, sortDirection, setState) => {
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
                sortColumn: sortColumn,
                key: this.getGridKey()
            }));
        }

        return {
            rows: sortedRows,
            sortDirection: sortDirection,
            sortColumn: sortColumn
        };
    };


    componentDidMount() {
        this.loadRows(false);
    }

    componentDidUpdate() {
        this.loadRows(false);
        this.updateScheduledDate();
    }
    render() {
        const { showProcNote, procNoteName, procNote, columns, rows } = this.state;
        const { selectedTimeline } = this.props;

        return (
                <div className='timeline-grid'>
                    <Modal show={showProcNote} onHide={this.handleNoteCancel} animation={false}>
                        <Modal.Header closeButton>
                            <Modal.Title>Procedure Note - {procNoteName}</Modal.Title>
                        </Modal.Header>
                        <Modal.Body>
                            <textarea className='timeline-grid-proc-note'
                                    ref={this.timelineProcNoteRef}
                                    defaultValue={procNote}
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
                                        variant="light"
                                        className='add-delete-btn'
                                        onClick={this.onAddClick}
                                        disabled={!selectedTimeline || selectedTimeline.IsInUse}
                                ><FontAwesomeIcon icon={faPlus}/></Button>
                            </OverlayTrigger>
                        </div>
                        <div className='col-sm-10' />
                    </div>
                    <div className='col-sm-12 zero-side-padding'>
                        {(!rows || rows.length === 0 || (rows.length === 1 && rows[0].RowIdx === 0)) ? (
                            this.EmptyRowsView()
                        ) : (
                            <DraggableContainer onHeaderDrop={this.onHeaderDrop} key={this.state.key}>
                                <DataGrid
                                        ref={this.dataGridRef}
                                        rows={rows}
                                        columns={columns}
                                        style={{ height: 'calc(67vh - 160px - 50px)' }}
                                        rowHeight={35}
                                        // headerRowHeight={200}
                                        onRowsChange={this.onRowsChange}
                                        onCellClick={this.onCellClick}
                                        rowClass={(row) => !this.isScheduleDateWithinRange(row) && row.TimelineItemId ? 'timeline-row-disabled' : undefined}
                                />
                            </DraggableContainer>
                        )}
                    </div>
                </div>
        );
    }
}

const mapStateToProps = state => ({
    selectedProject: state.project.selectedProject || null,
    selectedTimeline: state.timeline.selectedTimeline || null,
    lastRowIdx: state.timeline.selectedTimeline ? (state.timeline.selectedTimeline.lastRowIdx || 0) : 0
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
    onUpdateTimelineDayZero: (day0, forceReload, dirty) => dispatch(setTimelineDayZero(day0, forceReload, dirty))
})

export default connect(
        mapStateToProps,
        mapDispatchToProps
)(TimelineGrid)