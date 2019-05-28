


import {
    TIMELINE_LIST_RECEIVED,
    TIMELINE_CLONE,
    TIMELINE_REVISION,
    TIMELINE_SELECTED,
    TIMELINE_SAVE_SUCCESS,
    UPDATE_SELECTED_TIMELINE,
    TIMELINE_LIST_SORTED,
    ADD_TIMELINE_ITEM,
    UPDATE_TIMELINE_ROW,
    UPDATE_TIMELINE_ITEM,
    UPDATE_TIMELINE_PROJECT_ITEM,
    ASSIGN_TIMELINE_PROCEDURE,
    DELETE_TIMELINE_ITEM,
    NEW_TIMELINE,
    DELETE_NEW_TIMELINES,
    SET_TIMELINE_DAY_0,
    addDaysToDate, formatDateString, getNextRowId, TIMELINE_CLEAN, getDay0Date
} from "../actions/dataActions";
import {verboseOutput} from "./projectReducer";

function cloneTimeline(source, revision) {
    let newTimeline = Object.assign({ }, source);
    newTimeline = Object.assign(newTimeline, {
        TimelineId: revision ? source.TimelineId : -1,
        RowId: revision ? source.RowId : -1,
        RevisionNum: revision,
        Description: source.Description + (revision ? '': ' Clone'),
        IsDraft: true,
        IsDirty: true,
        ObjectId: undefined,
        CreatedByName: undefined,
        CreatedBy: undefined,
        Created: undefined,
        ModifiedByName: undefined,
        ModifiedBy: undefined,
        Modified: undefined,
        forceReload: false
    });
    newTimeline.TimelineItems = newTimeline.TimelineItems.map( item => {return {
        ...item,
        TimelineObjectId: undefined,
        ObjectId: undefined,
        TimelineItemId: undefined,
        IsDirty: true
    }});
    newTimeline.TimelineProjectItems = newTimeline.TimelineProjectItems.map( item => {return {
        ...item,
        TimelineObjectId: undefined,
        ObjectId: undefined,
        IsDirty: true
    }});


    return newTimeline;
}

function cloneArray(timelines) {
    return timelines.map( timeline => {
        return timeline;
    });
}

export default (state = { }, action) => {
    let nextState = Object.assign({ }, state);
    nextState.errors = [];
    switch (action.type) {
        case TIMELINE_LIST_RECEIVED:
            // action payload is the timeline array
            nextState.timelines = action.payload.timelines;

            // Add rowid, timelineitems, timelineprojectitems and timelineanimalitems for UI
            for (const tl of nextState.timelines) {
                tl.RowId = tl.TimelineId;

                if (!tl.TimelineItems) {
                    tl.TimelineItems = [];
                }

                if (!tl.TimelineProjectItems) {
                    tl.TimelineProjectItems = action.payload.selectedProject.ProjectItems.map((item, index) => {
                        return {ProjectItemId: item.projectItemId, SortOrder: index}
                    });
                }

                if (!tl.TimelineAnimalItems) {
                    tl.TimelineAnimalItems = [];
                }
            }

            nextState.lastRowId = getNextRowId(-1, nextState.timelines);
            break;
        case NEW_TIMELINE:

            const timelineTemplate = {
                RowId: getNextRowId(nextState.lastRowId, nextState.timelines),
                RevisionNum: 0,
                Description: "New Timeline",
                IsDeleted: false,
                IsDirty: true,
                QcState: 4,
                // TimelineProjectItems: action.payload.selectedProject.ProjectItems,
                TimelineAnimalItems: [],
                TimelineItems: [{RowIdx: 1, StudyDay: 0, ScheduleDate: null, IsDirty: true, IsDeleted: false, StudyDayNote: ''}]
            };

            let newTimeline = Object.assign({}, timelineTemplate, action.payload.timeline);
            newTimeline.TimelineProjectItems = action.payload.selectedProject.ProjectItems.map(item => {
                return {
                    ProjectItemId: item.projectItemId,
                    SortOrder: item._row - 1,
                    IsDeleted: false,
                    IsDirty: false,
                    TimelineFootNotes: null
                }
            });

            if (nextState.timelines) {
                nextState.timelines = cloneArray(nextState.timelines);
                nextState.timelines.push(newTimeline);
                nextState.selectedTimeline = newTimeline;
            }

            nextState.lastRowId = newTimeline.RowId;
            break;
        case TIMELINE_REVISION:
            const revision = cloneTimeline(action.payload, action.payload.RevisionNum + 1);
            nextState.timelines = cloneArray(nextState.timelines);
            nextState.timelines.push(revision);
            nextState.selectedTimeline = revision;
            break;
        case TIMELINE_CLONE:
            const clone = cloneTimeline(action.payload, 0);
            clone.RowId = getNextRowId(nextState.lastRowId, nextState.timelines);
            nextState.lastRowId = clone.RowId;
            nextState.timelines = cloneArray(nextState.timelines);
            nextState.timelines.push(clone);
            nextState.selectedTimeline = clone;
            break;
        case DELETE_NEW_TIMELINES:
            nextState.timelines = nextState.timelines.filter(timeline => {
                return (timeline.ObjectId || (action.payload && action.payload.RowId === timeline.RowId
                        && action.payload.RevisionNum === timeline.RevisionNum))
            });
            break;
        case TIMELINE_SELECTED:
            nextState.selectedTimeline = action.payload;

            // Set Study Day 0 if necessary
            if (nextState.selectedTimeline && !nextState.selectedTimeline.StudyDay0
                    && nextState.selectedTimeline.TimelineItems.length > 0 && nextState.selectedTimeline.TimelineItems[0].ScheduleDate) {
                const date = new Date(nextState.selectedTimeline.TimelineItems[0].ScheduleDate);
                nextState.selectedTimeline.StudyDay0 = getDay0Date(formatDateString(date), parseInt(nextState.selectedTimeline.TimelineItems[0].StudyDay));
            }
            break;
        case TIMELINE_CLEAN:
            nextState.selectedTimeline.IsDirty = false;
            break;
        case TIMELINE_SAVE_SUCCESS:

            if (!action.payload.TimelineItems) {
                action.payload.TimelineItems = [];
            }

            if (!action.payload.TimelineProjectItems) {
                action.payload.TimelineProjectItems = [];
            }

            if (!action.payload.TimelineAnimalItems) {
                action.payload.TimelineAnimalItems = [];
            }

            // add empty rows not saved
            // for (const timelineItem of nextState.selectedTimeline.TimelineItems) {
            //     if (!timelineItem.ProjectItemId) {
            //         action.payload.TimelineItems.push(timelineItem);
            //     }
            // }

            // Set rowid for UI display
            action.payload.RowId = action.payload.TimelineId;
            action.payload.IsDirty = false;

            // Update list of timelines
            let timelines = nextState.timelines.map((timeline) => {
                if (timeline.TimelineId && timeline.TimelineId === action.payload.TimelineId && timeline.RevisionNum === action.payload.RevisionNum) {
                    return action.payload;
                }
                return timeline;
            });

            nextState.timelines = timelines;
            nextState.selectedTimeline = action.payload;

            break;
        case ADD_TIMELINE_ITEM:
            // action payload is the timeline item
            if (nextState.selectedTimeline && nextState.selectedTimeline.TimelineItems) {
                nextState.selectedTimeline.TimelineItems.push(action.payload);
            }

            nextState.selectedTimeline.IsDirty = true;
            break;
        case UPDATE_TIMELINE_ROW:
            // action payload is timeline item
            nextState.selectedTimeline.TimelineItems = nextState.selectedTimeline.TimelineItems.map(item => {
                if(action.payload.RowIdx === item.RowIdx) {
                    item = Object.assign({ }, item);
                    item.StudyDay = parseInt(action.payload.StudyDay);
                    item.StudyDayNote = action.payload.StudyDayNote;
                    item.ScheduleDate = action.payload.ScheduleDate;
                }
                return item;
            });
            nextState.selectedTimeline.IsDirty = true;

            break;
        case UPDATE_TIMELINE_ITEM:
            // action payload is timeline item
            nextState.selectedTimeline.TimelineItems = nextState.selectedTimeline.TimelineItems.map(item => {
                if((action.payload.item.ObjectId && (action.payload.item.ObjectId === item.ObjectId))
                        || (!action.payload.item.ObjectId && (action.payload.item.RowIdx === item.RowIdx) && (action.payload.item.ProjectItemId === item.ProjectItemId))) {
                    return { ...item, ...action.payload.item }
                }
                else return item;
            });
            if (typeof action.payload.dirty !== 'undefined') {
                nextState.selectedTimeline.IsDirty = (action.payload.dirty || nextState.selectedTimeline.IsDirty);
            } else {
                nextState.selectedTimeline.IsDirty = true;
            }

            break;
        case UPDATE_SELECTED_TIMELINE:
            nextState.selectedTimeline = {...nextState.selectedTimeline, ...action.payload.timeline};
            if (typeof action.payload.dirty !== 'undefined') {
                nextState.selectedTimeline.IsDirty = (action.payload.dirty || nextState.selectedTimeline.IsDirty);
            } else {
                nextState.selectedTimeline.IsDirty = true;
            }
            break;
        case ASSIGN_TIMELINE_PROCEDURE:

            nextState.selectedTimeline.IsDirty = true;

            // Unchecking
            if (action.payload.Value === false) {

                // If unchecking a project item not persisted in db then just erase it
                nextState.selectedTimeline.TimelineItems = nextState.selectedTimeline.TimelineItems.filter(
                        item => (item.ObjectId || (action.payload.ProjectItemId !== item.ProjectItemId)
                                || (action.payload.RowIdx !== item.RowIdx))
                )

                // If persisted set IsDeleted flag
                nextState.selectedTimeline.TimelineItems = nextState.selectedTimeline.TimelineItems.map(item => {
                    if(item.ObjectId && (action.payload.ProjectItemId === item.ProjectItemId)
                            && (action.payload.RowIdx === item.RowIdx)) {
                        item.IsDeleted = true;
                    }

                    return item;
                })
            }
            // Check
            else {

                let found = false;

                // If empty project item saved
                nextState.selectedTimeline.TimelineItems = nextState.selectedTimeline.TimelineItems.map(item => {
                    if(!item.ProjectItemId && (action.payload.RowIdx === item.RowIdx)) {
                        item.ProjectItemId = action.payload.ProjectItemId;
                        found = true;
                    }

                    return item;
                })

                if (!found) {
                    nextState.selectedTimeline.TimelineItems.push({
                        IsDeleted: false,
                        TimelineObjectId: action.payload.TimelineObjectId,
                        StudyDay: action.payload.StudyDay,
                        StudyDayNote: action.payload.StudyDayNote,
                        IsDirty: false,
                        ScheduleDate: action.payload.ScheduleDate,
                        ProjectItemId: action.payload.ProjectItemId,
                        RowIdx: action.payload.RowIdx
                    })
                }
            }

            nextState.selectedTimeline.IsDirty = true;

            break;
        case UPDATE_TIMELINE_PROJECT_ITEM:
            nextState.selectedTimeline = {...nextState.selectedTimeline};
            nextState.selectedTimeline.TimelineProjectItems = nextState.selectedTimeline.TimelineProjectItems.map(projItem => {

                if (projItem.ProjectItemId === action.payload.ProjectItemId) {
                    projItem = { ...projItem, ...action.payload }
                }

                return projItem;
            });

            nextState.selectedTimeline.IsDirty = true;

            break;
        case DELETE_TIMELINE_ITEM:

            nextState.selectedTimeline.TimelineItems = nextState.selectedTimeline.TimelineItems.filter(item => {
                if (item.RowIdx === action.payload.RowIdx) {
                    if (item.ObjectId) {
                        item.IsDeleted = true;
                        return true;
                    }
                    else return false;
                }
                return true;
            });

            nextState.selectedTimeline.IsDirty = true;

            break;
        case SET_TIMELINE_DAY_0:
            const { day0, forceReload, IsDirty } = action.payload;

            nextState.selectedTimeline = Object.assign({ }, nextState.selectedTimeline);

            if (day0) {
                // Set in selected timeline for timeline details
                nextState.selectedTimeline.StudyDay0 = formatDateString(day0);
            }
            else {
                // Clearing day0
                nextState.selectedTimeline.StudyDay0 = day0;
            }

            // Calculate and update or clear timeline items scheduled dates
            let newTimelineItems = nextState.selectedTimeline.TimelineItems.map(item => {
                item = Object.assign({ }, item);
                if (day0 && item.StudyDay !== '' && typeof item.StudyDay !== 'undefined') {
                    item.ScheduleDate = addDaysToDate(day0, parseInt(item.StudyDay));
                }
                else {
                    item.ScheduleDate = null;
                }
                item.IsDirty = true;
                return item;
            });

            nextState.selectedTimeline.TimelineItems = newTimelineItems;
            nextState.selectedTimeline.forceReload = forceReload;

            if (typeof action.payload.dirty !== 'undefined') {
                nextState.selectedTimeline.IsDirty = (action.payload.dirty || nextState.selectedTimeline.IsDirty);
            } else {
                nextState.selectedTimeline.IsDirty = true;
            }

            break;
    };
    if (verboseOutput) {
        console.log('timelineReducer() -> ' + action.type + '\nnext state:');
        console.log(nextState);
    }
    return nextState;
};