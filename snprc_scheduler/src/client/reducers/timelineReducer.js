


import {
    TIMELINE_LIST_RECEIVED,
    TIMELINE_DUPLICATED,
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
    SET_TIMELINE_DAY_0,
    addDaysToDate, formatDateString
} from "../actions/dataActions";
import {verboseOutput} from "./projectReducer";

function cloneTimeline(source) {
    let nt = Object.assign({ }, source);
    nt = Object.assign(nt, { TimelineId: -1, revisionNum: -1, IsDraft: true });

    return nt;
}

export default (state = { }, action) => {
    let nextState = Object.assign({ }, state);
    let value = '';
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

            nextState.selectedTimeline = {};
            break;
        case NEW_TIMELINE:

            const timelineTemplate = {
                RevisionNum: 0,
                Description: "New Timeline",
                IsDeleted: false,
                IsDirty: false,
                QcState: 4,
                TimelineProjectItems: action.payload.selectedProject.ProjectItems,
                TimelineAnimalItems: [],
                TimelineItems: []
            };

            let newTimeline = Object.assign({}, timelineTemplate, action.payload.timeline);

            if (nextState.timelines) {
                nextState.timelines.push(newTimeline);
                nextState.selectedTimeline = newTimeline;
            }
            break;
        case TIMELINE_DUPLICATED:
            // action payload is the timeline object
            let clone = cloneTimeline(action.payload);
            nextState.timelines.push(clone);
            //nextState.allTimelines.push(clone);
            break;
        case TIMELINE_SELECTED:
            // action payload is the timeline object
            nextState.selectedTimeline = action.payload;
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
            for (const timelineItem of nextState.selectedTimeline.TimelineItems) {
                if (!timelineItem.ProjectItemId) {
                    action.payload.TimelineItems.push(timelineItem);
                }
            }

            // Set rowid for UI display
            action.payload.RowId = action.payload.TimelineId;

            // Update list of timelines
            let timelines = [];
            for (const timeline of nextState.timelines) {
                // Keep timelines with different timeline ids
                if (timeline.TimelineId && timeline.TimelineId !== action.payload.TimelineId) {
                    timelines.push(timeline);
                }
            }
            timelines.push(action.payload);

            nextState.timelines = timelines;
            nextState.selectedTimeline = action.payload;

            break;
        case ADD_TIMELINE_ITEM:
            // action payload is the timeline item
            if (nextState.selectedTimeline && nextState.selectedTimeline.TimelineItems) {
                nextState.selectedTimeline.TimelineItems.push(action.payload);
            }

            nextState.selectedTimeline.isDirty = true;
            break;
        case UPDATE_TIMELINE_ROW:
            // action payload is timeline item
            nextState.selectedTimeline.TimelineItems = nextState.selectedTimeline.TimelineItems.map(item => {
                if(action.payload.RowIdx === item.RowIdx) {
                    item = Object.assign({ }, item);
                    item.StudyDay = parseInt(action.payload.StudyDay);
                    item.ScheduleDate = action.payload.ScheduleDate;
                }
                return item;
            });
            nextState.selectedTimeline.isDirty = true;

            break;
        case UPDATE_TIMELINE_ITEM:
            // action payload is timeline item
            nextState.selectedTimeline.TimelineItems = nextState.selectedTimeline.TimelineItems.map(item => {
                if((action.payload.ObjectId && (action.payload.ObjectId === item.ObjectId))
                        || (!action.payload.ObjectId && (action.payload.RowIdx === item.RowIdx) && (action.payload.ProjectItemId === item.ProjectItemId))) {
                    return { ...item, ...action.payload }
                }
                else return item;
            });
            nextState.selectedTimeline.isDirty = true;

            break;
        case UPDATE_SELECTED_TIMELINE:
            nextState.selectedTimeline = {...nextState.selectedTimeline, ...action.payload};
            nextState.selectedTimeline.isDirty = true;
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
                        IsDirty: false,
                        ScheduleDate: action.payload.ScheduleDate,
                        ProjectItemId: action.payload.ProjectItemId,
                        RowIdx: action.payload.RowIdx
                    })
                }
            }

            nextState.selectedTimeline.isDirty = true;

            break;
        case UPDATE_TIMELINE_PROJECT_ITEM:

            nextState.selectedTimeline.TimelineProjectItems = nextState.selectedTimeline.TimelineProjectItems.map(projItem => {

                if (projItem.ProjectItemId === action.payload.ProjectItemId) {
                    projItem = { ...projItem, ...action.payload }
                }

                return projItem;
            });

            nextState.selectedTimeline.isDirty = true;

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

            nextState.selectedTimeline.isDirty = true;

            break;
        case SET_TIMELINE_DAY_0:
            const { day0, forceReload } = action.payload;

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
                if (day0) {
                    item.ScheduleDate = addDaysToDate(action.payload.day0, parseInt(item.StudyDay));
                }
                else {
                    item.ScheduleDate = null;
                }
                item.IsDirty = true;
                return item;
            });

            nextState.selectedTimeline.TimelineItems = newTimelineItems;
            nextState.selectedTimeline.isDirty = true;
            nextState.selectedTimeline.forceReload = action.payload.forceReload;

            break;
    };
    if (verboseOutput) {
        console.log('timelineReducer() -> ' + action.type + '\nnext state:');
        console.log(nextState);
    }
    return nextState;
};