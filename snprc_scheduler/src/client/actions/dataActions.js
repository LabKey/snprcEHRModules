/* 
    ==================================================================================
    author:             David P. Smith
    email:              dsmith@txbiomed.org
    name:               snprc_scheduler
    description:        Animal procedure scheduling system     
    copyright:          Texas Biomedical Research Institute
    created:            October 9 2018      
    ==================================================================================
*/

export const EXPAND_ACCORDION_TAB = 'EXPAND_ACCORDION_TAB';
export const PROJECT_LIST_REQUESTED = 'PROJECT_LIST_REQUESTED';
export const PROJECT_LIST_RECEIVED = 'PROJECT_LIST_RECEIVED';
export const PROJECT_LIST_REQUEST_FAILED = 'PROJECT_LIST_REQUEST_FAILED';
export const ANIMAL_LIST_REQUESTED = 'ANIMAL_LIST_REQUESTED';
export const ANIMAL_LIST_RECEIVED = 'ANIMAL_LIST_RECEIVED';
export const ANIMAL_LIST_REQUEST_FAILED = 'ANIMAL_LIST_REQUEST_FAILED';
export const ANIMAL_ASSIGNED = 'ANIMAL_ASSIGNED';
export const UPDATE_ASSIGNED_ANIMALS = 'UPDATE_ASSIGNED_ANIMALS';
export const AVAILABLE_ANIMAL_LIST_FILTERED = 'AVAILABLE_ANIMAL_LIST_FILTERED';
export const ASSIGNED_ANIMAL_LIST_FILTERED = 'ASSIGNED_ANIMAL_LIST_FILTERED';
export const PROJECT_SELECTED = 'PROJECT_SELECTED';
export const PROJECT_LIST_FILTERED = 'PROJECT_LIST_FILTERED';
export const TIMELINE_LIST_REQUESTED = 'TIMELINE_LIST_REQUESTED';
export const TIMELINE_LIST_RECEIVED = 'TIMELINE_LIST_RECEIVED';
export const TIMELINE_LIST_REQUEST_FAILED = 'TIMELINE_LIST_REQUEST_FAILED';
export const TIMELINE_CREATED = 'TIMELINE_CREATED';
export const TIMELINE_SELECTED = 'TIMELINE_SELECTED';
export const TIMELINE_SAVE_SUCCESS = 'TIMELINE_SAVE_SUCCESS';
export const UPDATE_SELECTED_TIMELINE = 'UPDATE_SELECTED_TIMELINE';
export const ADD_TIMELINE_ANIMAL_ITEM = 'ADD_TIMELINE_ANIMAL_ITEM';
export const DELETE_TIMELINE_ANIMAL_ITEM = 'DELETE_TIMELINE_ANIMAL_ITEM';
export const UPDATE_TIMELINE_ANIMAL_ITEM = 'UPDATE_TIMELINE_ANIMAL_ITEM';
export const TIMELINE_REMOVED = 'TIMELINE_REMOVED';
export const TIMELINE_CLONE = 'TIMELINE_CLONE';
export const TIMELINE_REVISION = 'TIMELINE_REVISION';
export const TIMELINE_STATE_CHANGED = 'TIMELINE_STATE_CHANGED';
export const TIMELINE_DROPPED_ON_CALENDAR = 'TIMELINE_DROPPED_ON_CALENDAR';
export const TIMELINE_ITEM_CREATED = 'TIMELINE_ITEM_CREATED';
export const TIMELINE_ITEM_SELECTED = 'TIMELINE_ITEM_SELECTED';
export const TIMELINE_ITEM_REMOVED = 'TIMELINE_ITEM_REMOVED';
export const ADD_TIMELINE_ITEM = 'ADD_TIMELINE_ITEM';
export const UPDATE_TIMELINE_ROW = 'UPDATE_TIMELINE_ROW';
export const UPDATE_TIMELINE_ITEM = 'UPDATE_TIMELINE_ITEM';
export const UPDATE_STUDY_DAY_NOTE = 'UPDATE_STUDY_DAY_NOTE';
export const UPDATE_TIMELINE_PROJECT_ITEM = 'UPDATE_TIMELINE_PROJECT_ITEM';
export const ASSIGN_TIMELINE_PROCEDURE = 'ASSIGN_TIMELINE_PROCEDURE';
export const DELETE_TIMELINE_ITEM = 'DELETE_TIMELINE_ITEM';
export const PROJECT_LIST_SORTED = 'PROJECT_LIST_SORTED';
export const SET_TIMELINE_DAY_0 = 'SET_TIMELINE_DAY_0';
export const TIMELINE_LIST_SORTED = 'TIMELINE_LIST_SORTED';
export const NEW_TIMELINE = 'NEW_TIMELINE';
export const DELETE_NEW_TIMELINES = 'DELETE_NEW_TIMELINES';
export const DELETE_TIMELINE = 'DELETE_TIMELINE';
export const TIMELINE_CLEAN = 'TIMELINE_CLEAN';
export const SHOW_CONFIRM = 'SHOW_CONFIRM';
export const HIDE_CONFIRM = 'HIDE_CONFIRM';
export const SHOW_ALERT_MODAL = 'SHOW_ALERT_MODAL';
export const HIDE_ALERT_MODAL = 'HIDE_ALERT_MODAL';
export const SHOW_ALERT_BANNER = 'SHOW_ALERT_BANNER';
export const HIDE_ALERT_BANNER = 'HIDE_ALERT_BANNER';
export const SHOW_LOADING = 'SHOW_LOADING';
export const HIDE_LOADING = 'HIDE_LOADING';
export const HAS_PERMISSION = 'HAS_PERMISSION';
export const FORCE_RERENDER = 'FORCE_RERENDER';
export const NO_OP = 'NO_OP';

export const TAB_PROJECTS = 0x0;
export const TAB_TIMELINES = 0x1;
export const TAB_ANIMALS = 0x2;

export const getBaseURI = () => {
    let data = (window.location+'').toString().split('//');
    return data[0]+'//'+data[1].split('/')[0];
}

const verboseOutput = false;

export function createAction(type, payload) {
    switch(type) {
        case PROJECT_LIST_REQUESTED: return { type: type };
        case EXPAND_ACCORDION_TAB: return { type: type, payload: payload };
        case PROJECT_LIST_RECEIVED: return { type: type, payload: payload };
        case PROJECT_LIST_REQUEST_FAILED: return { type: type, payload: payload, error: true };
        case ANIMAL_LIST_REQUESTED: return { type: type };
        case ANIMAL_LIST_RECEIVED: return { type: type, payload: payload };
        case ANIMAL_LIST_REQUEST_FAILED: return { type: type, payload: payload, error: true };
        case ANIMAL_ASSIGNED: return { type: type, payload: payload };
        case UPDATE_ASSIGNED_ANIMALS: return { type: type, payload: payload };
        case PROJECT_SELECTED: return { type: type, payload: payload };
        case PROJECT_LIST_FILTERED: return { type: type, payload: payload };
        case AVAILABLE_ANIMAL_LIST_FILTERED: return { type: type, payload: payload };
        case ASSIGNED_ANIMAL_LIST_FILTERED: return { type: type, payload: payload };
        case TIMELINE_LIST_REQUESTED: return { type: type };
        case TIMELINE_LIST_RECEIVED: return { type: type, payload: payload };
        case TIMELINE_LIST_REQUEST_FAILED: return { type: type, payload: payload, error: true };
        case TIMELINE_SELECTED: return { type: type, payload: payload };
        case TIMELINE_SAVE_SUCCESS: return { type: type, payload: payload };
        case UPDATE_SELECTED_TIMELINE: return { type: type, payload: payload };
        case TIMELINE_REVISION: return { type: type, payload: payload };
        case TIMELINE_CLONE: return { type: type, payload: payload };
        case TIMELINE_ITEM_CREATED: return { type: type, payload: payload };
        case TIMELINE_ITEM_REMOVED: return { type: type, payload: payload };
        case TIMELINE_ITEM_SELECTED: return { type: type, payload: payload };
        case ADD_TIMELINE_ITEM: return { type: type, payload: payload };
        case UPDATE_TIMELINE_ROW: return { type: type, payload: payload };
        case UPDATE_TIMELINE_ITEM: return { type: type, payload: payload };
        case UPDATE_STUDY_DAY_NOTE: return { type: type, payload: payload };
        case ADD_TIMELINE_ANIMAL_ITEM: return { type: type, payload: payload };
        case DELETE_TIMELINE_ANIMAL_ITEM: return { type: type, payload: payload };
        case UPDATE_TIMELINE_ANIMAL_ITEM: return { type: type, payload: payload };
        case UPDATE_TIMELINE_PROJECT_ITEM: return { type: type, payload: payload };
        case ASSIGN_TIMELINE_PROCEDURE: return { type: type, payload: payload };
        case DELETE_TIMELINE_ITEM: return { type: type, payload: payload };
        case SET_TIMELINE_DAY_0: return { type: type, payload: payload };
        case TIMELINE_LIST_SORTED: return { type: type, payload: payload };
        case NEW_TIMELINE: return { type: type, payload: payload };
        case DELETE_NEW_TIMELINES: return { type: type, payload: payload };
        case DELETE_TIMELINE: return { type: type, payload: payload };
        case PROJECT_LIST_SORTED: return { type: type, payload: payload };
        case TIMELINE_CLEAN: return { type: type, payload: payload };
        case SHOW_CONFIRM: return { type: type, payload: payload };
        case HIDE_CONFIRM: return { type: type, payload: payload };
        case SHOW_ALERT_MODAL: return { type: type, payload: payload };
        case HIDE_ALERT_MODAL: return { type: type, payload: payload };
        case SHOW_ALERT_BANNER: return { type: type, payload: payload };
        case HIDE_ALERT_BANNER: return { type: type, payload: payload };
        case SHOW_LOADING: return { type: type };
        case HIDE_LOADING: return { type: type };
        case HAS_PERMISSION: return { type: type, payload: payload };
        case FORCE_RERENDER: return { type: type, payload: payload };
        default: return { type: type }
    }    
}

export function handleErrors(baseMsg, error) {
    return (dispatch) => {
        dispatch(hideLoading());
        if (error && error.exception) {
            dispatch(showAlertBanner({show: true, variant: 'danger', msg: baseMsg + ": " + error.exception}));
            console.warn('save project error', error.exception);
        }
        else if (error && error.errors) {
            dispatch(showAlertBanner({show: true, variant: 'danger', msg: baseMsg + ": " + error.errors[0].msg}));
            console.warn('save project error', error.errors[0].msg);
        }
        else if (error && error.message) {
            dispatch(showAlertBanner({show: true, variant: 'danger', msg: baseMsg + ": " + error.message}));
            console.warn('save project error', error.message);
        }
    }
}

export function saveTimeline(timelineData) {
    return new Promise((resolve, reject) => {
        LABKEY.Ajax.request({
            method: 'POST',
            url: LABKEY.ActionURL.buildURL('SNPRC_scheduler', 'updateTimeline.api'),
            jsonData: timelineData,
            success: LABKEY.Utils.getCallbackWrapper((data) => {
                resolve(data);
            }),
            failure: LABKEY.Utils.getCallbackWrapper((data) => {
                reject(data);
            })
        });
    })
}

function fetchProjects_LABKEY() {
    return (dispatch) => {
        dispatch(createAction(PROJECT_LIST_REQUESTED));
        LABKEY.Query.selectRows({
            queryName: 'ProjectDetails', requiredVersion: 9.1, schemaName: 'snd', filterArray: [], sort: 'ProjectId,RevisionNum',
            columns: 'ProjectId,RevisionNum,ChargeId,Description,StartDate,EndDate,ProjectType,VsNumber,Active,ObjectId,iacuc,veterinarian',
            success: (results) => { dispatch(createAction(PROJECT_LIST_RECEIVED, results.rows)); },
            failure: (error) => { dispatch(createAction(PROJECT_LIST_REQUEST_FAILED, error)); }
        });
    };
}

function fetchProjects_SND() {
    const API_ENDPOINT = LABKEY.ActionURL.getBaseURL() + LABKEY.ActionURL.getContainer() + '/SNPRC_Scheduler-getActiveProjects.view';
    return (dispatch) => {
        dispatch(showLoading());
        dispatch(createAction(PROJECT_LIST_REQUESTED));
        fetch(API_ENDPOINT)
                .then(response => {
                    if (response.status === 403) {
                        dispatch(hideLoading());
                        dispatch(setPermission(false));
                    }
                    else {
                        dispatch(setPermission(true));
                        response.json()
                                .then(data => {
                                    if (data.success) {
                                        dispatch(createAction(PROJECT_LIST_RECEIVED, data.rows));

                                        // Sort matches defaultSort on projects table to select first project
                                        dispatch(selectProject(data.rows.sort(function (a, b) {
                                            if (!a.description) {
                                                return 1;
                                            }
                                            if (!b.description) {
                                                return -1;
                                            }
                                            return (a.description > b.description ? 1 : -1)
                                        })[0]));
                                    }
                                    else {
                                        console.error("Retrieving projects failed.", data.message);
                                        dispatch(handleErrors("Retrieving projects failed.", data.message));
                                    }
                                })
                    }
                })
                .catch((error) => {
                    console.error("Retrieving projects failed", error);
                    dispatch(handleErrors("Retrieving projects failed", error))
                });
    }
}

export function fetchProjects() {
    if (verboseOutput) console.log('fetchProjects()');
    return fetchProjects_SND();
}

export function fetchAnimalsByProject(projectId, revision) {
    if (verboseOutput) console.log('fetchAnimalsByProject(' + projectId + ',' + revision + ')');
    return (dispatch) => {
        dispatch(createAction(ANIMAL_LIST_REQUESTED));
        LABKEY.Query.selectRows({
            queryName: 'AnimalsByProject', requiredVersion: 9.1, schemaName: 'snd', filterArray: [
                LABKEY.Filter.create('ProjectId', projectId.toString(), LABKEY.Filter.Types.EQUAL),
                LABKEY.Filter.create('RevisionNum', revision.toString(), LABKEY.Filter.Types.EQUAL)
            ],
            columns: 'Id,ProjectId,RevisionNum,StartDate,EndDate,Gender,ChargeId,Iacuc,AssignmentStatus,Weight,Age',
            success: (results) => {
                dispatch(createAction(ANIMAL_LIST_RECEIVED, results.rows));
            },
            failure: (error) => {
                dispatch(createAction(ANIMAL_LIST_RECEIVED, []));
                dispatch(handleErrors("Retrieving animals failed", error));
            }
        });
    };
}

export function fetchTimelinesByProject(selectedProject) {
    if (verboseOutput) console.log('fetchTimelinesByProject(' + selectedProject.objectId + ')');
    const API_ENDPOINT = LABKEY.ActionURL.getBaseURL() + LABKEY.ActionURL.getContainer() + '/SNPRC_Scheduler-getActiveTimelines.view?projectObjectId=' + selectedProject.objectId;
    return (dispatch) => {
        dispatch(createAction(TIMELINE_LIST_REQUESTED, selectedProject.objectId));
        fetch(API_ENDPOINT)
                .then(response => {
                    if (response.status === 403) {
                        dispatch(setPermission(false));
                    }
                    else {
                        dispatch(setPermission(true));
                        response.json()
                                .then(data => {
                                    if (data.success) {
                                        dispatch(hideLoading()); // last API call in initial loading sequence
                                        dispatch(createAction(TIMELINE_LIST_RECEIVED, {
                                            timelines: data.rows,
                                            selectedProject: selectedProject
                                        }));
                                    }
                                    else {
                                        dispatch(handleErrors("Retrieving timelines failed", data));
                                    }
                                })
                                .catch((error) => dispatch(handleErrors("Retrieving timelines failed", error)));
                    }
                })
    }
}

export function expandAccordionTab(tab) {
    if (verboseOutput) console.log('EXPAND_ACCORDION_TAB');
    return (dispatch) => {
        dispatch(createAction(EXPAND_ACCORDION_TAB, tab));
    }
}

export function showConfirm(confirm) {
    if (verboseOutput) console.log('SHOW_CONFIRM');
    return (dispatch) => {
        dispatch(createAction(SHOW_CONFIRM, confirm));
    }
}

export function hideConfirm(confirm) {
    if (verboseOutput) console.log('HIDE_CONFIRM');
    return (dispatch) => {
        dispatch(createAction(HIDE_CONFIRM, confirm));
    }
}

export function showAlertModal(alert) {
    if (verboseOutput) console.log('SHOW_ALERT_MODAL');
    return (dispatch) => {
        dispatch(createAction(SHOW_ALERT_MODAL, alert));
    }
}

export function hideAlertModal(alert) {
    if (verboseOutput) console.log('HIDE_ALERT_MODAL');
    return (dispatch) => {
        dispatch(createAction(HIDE_ALERT_MODAL, alert));
    }
}

export function showAlertBanner(alert) {
    if (verboseOutput) console.log('SHOW_ALERT_BANNER');
    return (dispatch) => {
        dispatch(createAction(SHOW_ALERT_BANNER, alert));
    }
}

export function hideAlertBanner(alert) {
    if (verboseOutput) console.log('HIDE_ALERT_BANNER');
    return (dispatch) => {
        dispatch(createAction(HIDE_ALERT_BANNER, alert));
    }
}

export function showLoading() {
    if (verboseOutput) console.log('SHOW_LOADING');
    return (dispatch) => {
        dispatch(createAction(SHOW_LOADING));
    }
}

export function hideLoading(alert) {
    if (verboseOutput) console.log('HIDE_LOADING');
    return (dispatch) => {
        dispatch(createAction(HIDE_LOADING));
    }
}

export function filterProjects(pattern) {
    if (verboseOutput) console.log('filterProjects(' + pattern + ')');
    return (dispatch) => {
        dispatch(createAction(PROJECT_LIST_FILTERED, pattern));
    }
}

export function sortProjects(field, direction) {
    if (verboseOutput) console.log('sortProjects(' + field + ',' + direction + ')');
    return (dispatch) => {
        dispatch(createAction(PROJECT_LIST_SORTED, { field: field, direction: direction }));
    }
}

export function filterAnimals(pattern) {
    if (verboseOutput) console.log('filterAnimals(' + pattern + ')');
    return (dispatch) => {
        dispatch(createAction(ANIMAL_LIST_FILTERED, pattern));
    }
}

export function selectProject(selectedProject) {
    if (verboseOutput) console.log('selectProject(' + selectedProject.projectId + ',' + selectedProject.revisionNum + ')');
    return (dispatch) => {
        dispatch(createAction(PROJECT_SELECTED, selectedProject.projectId));
        dispatch(fetchAnimalsByProject(selectedProject.projectId, selectedProject.revisionNum));
        dispatch(fetchTimelinesByProject(selectedProject));  // This will hide loading mask on success
    }
}

export function selectTimeline(timeline) {
    if (verboseOutput) console.log('selectTimeline(' + timeline.TimelineId + ',' + timeline.RevisionNum + ')');
    return (dispatch) => {
        dispatch(createAction(TIMELINE_SELECTED, timeline));
        dispatch(createAction(UPDATE_ASSIGNED_ANIMALS, timeline?timeline.TimelineAnimalItems:[]));
        if (timeline && timeline.IsInUse && timeline.Description) {
            dispatch(showAlertBanner({show: true, variant: 'warning', msg: timeline.Description + ', Revision ' + timeline.RevisionNum + ' is in use.'}))
        } else {
            dispatch(hideAlertBanner());
        }
    }    
}

export function addTimelineAnimalItem(item, timeline) {
    if (verboseOutput) console.log('addTimelineItem(timelineId: ' + timeline.TimelineId + ', animalId: ' + id + ')');
    return (dispatch) => {
        dispatch(createAction(ADD_TIMELINE_ANIMAL_ITEM, item));
        dispatch(createAction(UPDATE_ASSIGNED_ANIMALS, timeline.TimelineAnimalItems));
        if (timeline && timeline.IsInUse && timeline.Description) {
            dispatch(showAlertBanner({show: true, variant: 'warning', msg: timeline.Description + ', Revision ' + timeline.RevisionNum + ' is in use.'}))
        } else {
            dispatch(hideAlertBanner());
        }
    }
}

export function deleteTimelineAnimalItem(id, timeline) {
    if (verboseOutput) console.log('deleteTimelineItem(timelineId: ' + timeline.TimelineId + ', animalId: ' + id + ')');
    return (dispatch) => {
        dispatch(createAction(DELETE_TIMELINE_ANIMAL_ITEM, id));
        dispatch(createAction(UPDATE_ASSIGNED_ANIMALS, timeline.TimelineAnimalItems));
        if (timeline && timeline.IsInUse && timeline.Description) {
            dispatch(showAlertBanner({show: true, variant: 'warning', msg: timeline.Description + ', Revision ' + timeline.RevisionNum + ' is in use.'}))
        } else {
            dispatch(hideAlertBanner());
        }
    }
}

export function updateTimelineAnimalItem(item, timeline) {
    if (verboseOutput) console.log('enddateTimelineAnimalItem(timelineId: ' + timeline.TimelineId + ', animalId: ' + item.AnimalId + ')');
    return (dispatch) => {
        dispatch(createAction(UPDATE_TIMELINE_ANIMAL_ITEM, item));
        dispatch(createAction(UPDATE_ASSIGNED_ANIMALS, timeline.TimelineAnimalItems));
        if (timeline && timeline.IsInUse && timeline.Description) {
            dispatch(showAlertBanner({show: true, variant: 'warning', msg: timeline.Description + ', Revision ' + timeline.RevisionNum + ' is in use.'}))
        } else {
            dispatch(hideAlertBanner());
        }
    }
}

export function sortTimelines(timelines) {
    timelines = timelines.sort(function(a, b){
        if (!a.Description) {
            return 1;
        }
        if (!b.Description) {
            return -1;
        }

        if (a.Description === b.Description) {
            return (a.RevisionNum > b.RevisionNum ? 1 : -1)
        }
        return (a.Description > b.Description ? 1 : -1)
    });

    return timelines;
}

export function selectFirstTimeline(timelines) {
    if (timelines) {
        timelines = sortTimelines(timelines);
        return selectTimeline(timelines[0]);
    }
}

// export function duplicateTimeline(timeline) {
//     if (verboseOutput) console.log('duplicateTimeline(' + timeline.TimelineId + ',' + timeline.RevisionNum + ')');
//     return (dispatch) => {
//         dispatch(createAction(TIMELINE_DUPLICATED, timeline));
//     }
// }

export function addTimelineItem(item) {
    if (verboseOutput) console.log('addTimelineItem(Study Day: ' + item.StudyDay);
    return (dispatch) => {
        dispatch(createAction(ADD_TIMELINE_ITEM, item));
    }
}

export function updateTimelineRow(item) {
    if (verboseOutput) console.log('updateTimelineRow - Study Day: ' + item.StudyDay);
    return (dispatch) => {
        dispatch(createAction(UPDATE_TIMELINE_ROW, item));
    }
}

export function updateTimelineItem(item, dirty) {
    if (verboseOutput) console.log('updateTimelineItem - Study Day: ' + item.StudyDay);
    return (dispatch) => {
        dispatch(createAction(UPDATE_TIMELINE_ITEM, {item: item, dirty: dirty}));
    }
}

export function updateStudyDayNote(note, dirty) {
    if (verboseOutput) console.log('UPDATE_STUDY_DAY_NOTE - Study Day: ' + note.StudyDay);
    return (dispatch) => {
        dispatch(createAction(UPDATE_STUDY_DAY_NOTE, {note: note, dirty: dirty}));
    }
}

export function updateSelectedTimeline(timeline, dirty) {
    if (verboseOutput) console.log('updateSelectedTimeline');
    return (dispatch) => {
        dispatch(createAction(UPDATE_SELECTED_TIMELINE, {timeline: timeline, dirty: dirty}));
    }
}

export function saveTimelineSuccess(timeline) {
    if (verboseOutput) console.log('updateSelectedTimeline');
    return (dispatch) => {
        dispatch(createAction(TIMELINE_SAVE_SUCCESS, timeline));
    }
}

export function assignTimelineProcedure(item) {
    if (verboseOutput) console.log('ASSIGN_TIMELINE_PROCEDURE');
    return (dispatch) => {
        dispatch(createAction(ASSIGN_TIMELINE_PROCEDURE, item));
    }
}

export function updateTimelineProjectItem(projectItem) {
    if (verboseOutput) console.log('UPDATE_TIMELINE_PROJECT_ITEM');
    return (dispatch) => {
        dispatch(createAction(UPDATE_TIMELINE_PROJECT_ITEM, projectItem));
    }
}

export function deleteTimelineItem(timelineItem) {
    if (verboseOutput) console.log('DELETE_TIMELINE_ITEM');
    return (dispatch) => {
        dispatch(createAction(DELETE_TIMELINE_ITEM, timelineItem));
    }
}

export function newTimeline(timeline, selectedProject) {
    if (verboseOutput) console.log('NEW_TIMELINE');
    return (dispatch) => {
        dispatch(createAction(NEW_TIMELINE, {timeline: timeline, selectedProject: selectedProject}));
    }
}

export function cloneTimeline(timeline) {
    if (verboseOutput) console.log('TIMELINE_CLONE');
    return (dispatch) => {
        dispatch(createAction(TIMELINE_CLONE, timeline));
    }
}

export function reviseTimeline(timeline) {
    if (verboseOutput) console.log('TIMELINE_REVISION');
    return (dispatch) => {
        dispatch(createAction(TIMELINE_REVISION, timeline));
    }
}

export function deleteNewTimelines(timeline) {
    if (verboseOutput) console.log('DELETE_NEW_TIMELINES');
    return (dispatch) => {
        dispatch(createAction(DELETE_NEW_TIMELINES, timeline));
    }
}

export function setTimelineDayZero(day0, forceReload, dirty) {
    if (verboseOutput) console.log('SET_TIMELINE_DAY_0');
    return (dispatch) => {
        dispatch(createAction(SET_TIMELINE_DAY_0, {day0: day0, forceReload: forceReload, dirty: dirty}));
    }
}

export function setTimelineClean(timeline) {
    if (verboseOutput) console.log('TIMELINE_CLEAN');
    return (dispatch) => {
        dispatch(createAction(TIMELINE_CLEAN, timeline));
    }
}

export function setPermission(permission) {
    if (verboseOutput) console.log('HAS_PERMISSION');
    return (dispatch) => {
        dispatch(createAction(HAS_PERMISSION, permission));
    }
}

export function setForceRerender(render) {
    if (verboseOutput) console.log('FORCE_RERENDER');
    return (dispatch) => {
        dispatch(createAction(FORCE_RERENDER, render));
    }
}

export function setAvailableAnimalFilter(filter) {
    if (verboseOutput) console.log('AVAILABLE_ANIMAL_LIST_FILTERED');
    return (dispatch) => {
        dispatch(createAction(AVAILABLE_ANIMAL_LIST_FILTERED, filter));
    }
}

export function setAssignedAnimalFilter(filter) {
    if (verboseOutput) console.log('ASSIGNED_ANIMAL_LIST_FILTERED');
    return (dispatch) => {
        dispatch(createAction(ASSIGNED_ANIMAL_LIST_FILTERED, filter));
    }
}

export function assignAnimal(id) {
    if (verboseOutput) console.log('ANIMAL_ASSIGNED');
    return (dispatch) => {
        dispatch(createAction(ANIMAL_ASSIGNED, id));
    }
}

export function formatDateString(date) {
    let newDate = new Date(date);
    return newDate.toISOString().substring(0, "yyyy-MM-dd".length)
}

export function addDaysToDate(date, days) {
    let result = new Date(date);
    result.setDate(result.getDate() + days);
    return formatDateString(result);
}

export function getDay0Date(date, days) {
    let result = new Date(date);
    result.setDate(result.getDate() - days);
    return formatDateString(result);
}

export function getNextRowId(id, timelines) {
    do {
        id++;
    } while (timelines.find(timeline => {return timeline.RowId === id}));

    return id;
}