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

export const PROJECT_LIST_REQUESTED = 'PROJECT_LIST_REQUESTED';
export const PROJECT_LIST_RECEIVED = 'PROJECT_LIST_RECEIVED';
export const PROJECT_LIST_REQUEST_FAILED = 'PROJECT_LIST_REQUEST_FAILED';
export const ANIMAL_LIST_REQUESTED = 'ANIMAL_LIST_REQUESTED';
export const ANIMAL_LIST_RECEIVED = 'ANIMAL_LIST_RECEIVED';
export const ANIMAL_LIST_REQUEST_FAILED = 'ANIMAL_LIST_REQUEST_FAILED';
export const ANIMAL_LIST_FILTERED = 'ANIMAL_LIST_FILTERED';
export const PROJECT_SELECTED = 'PROJECT_SELECTED';
export const PROJECT_LIST_FILTERED = 'PROJECT_LIST_FILTERED';
export const TIMELINE_LIST_REQUESTED = 'TIMELINE_LIST_REQUESTED';
export const TIMELINE_LIST_RECEIVED = 'TIMELINE_LIST_RECEIVED';
export const TIMELINE_LIST_REQUEST_FAILED = 'TIMELINE_LIST_REQUEST_FAILED';
export const TIMELINE_CREATED = 'TIMELINE_CREATED';
export const TIMELINE_SELECTED = 'TIMELINE_SELECTED';
export const TIMELINE_SAVE_SUCCESS = 'TIMELINE_SAVE_SUCCESS';
export const UPDATE_SELECTED_TIMELINE = 'UPDATE_SELECTED_TIMELINE';
export const TIMELINE_REMOVED = 'TIMELINE_REMOVED';
export const TIMELINE_DUPLICATED = 'TIMELINE_DUPLICATED';
export const TIMELINE_STATE_CHANGED = 'TIMELINE_STATE_CHANGED';
export const TIMELINE_DROPPED_ON_CALENDAR = 'TIMELINE_DROPPED_ON_CALENDAR';
export const TIMELINE_ITEM_CREATED = 'TIMELINE_ITEM_CREATED';
export const TIMELINE_ITEM_SELECTED = 'TIMELINE_ITEM_SELECTED';
export const TIMELINE_ITEM_REMOVED = 'TIMELINE_ITEM_REMOVED';
export const ADD_TIMELINE_ITEM = 'ADD_TIMELINE_ITEM';
export const UPDATE_TIMELINE_ROW = 'UPDATE_TIMELINE_ROW';
export const UPDATE_TIMELINE_ITEM = 'UPDATE_TIMELINE_ITEM';
export const UPDATE_TIMELINE_PROJECT_ITEM = 'UPDATE_TIMELINE_PROJECT_ITEM';
export const ASSIGN_TIMELINE_PROCEDURE = 'ASSIGN_TIMELINE_PROCEDURE';
export const DELETE_TIMELINE_ITEM = 'DELETE_TIMELINE_ITEM';
export const PROJECT_LIST_SORTED = 'PROJECT_LIST_SORTED';
export const TIMELINE_LIST_SORTED = 'TIMELINE_LIST_SORTED';
export const NEW_TIMELINE = 'NEW_TIMELINE';
export const NO_OP = 'NO_OP';

export const getBaseURI = () => {
    let data = (window.location+'').toString().split('//');
    return data[0]+'//'+data[1].split('/')[0];
}

export const BASE_URI = getBaseURI();
export const BASE_API = '/labkey/snprc_scheduler/snprc/';

const verboseOutput = false;

export function createAction(type, payload) {
    switch(type) {
        case PROJECT_LIST_REQUESTED: return { type: type };
        case PROJECT_LIST_RECEIVED: return { type: type, payload: payload };
        case PROJECT_LIST_REQUEST_FAILED: return { type: type, payload: payload, error: true };
        case ANIMAL_LIST_REQUESTED: return { type: type };
        case ANIMAL_LIST_RECEIVED: return { type: type, payload: payload };
        case ANIMAL_LIST_REQUEST_FAILED: return { type: type, payload: payload, error: true };
        case PROJECT_SELECTED: return { type: type, payload: payload };
        case PROJECT_LIST_FILTERED: return { type: type, payload: payload };
        case ANIMAL_LIST_FILTERED: return { type: type, payload: payload };
        case TIMELINE_LIST_REQUESTED: return { type: type };
        case TIMELINE_LIST_RECEIVED: return { type: type, payload: payload };
        case TIMELINE_LIST_REQUEST_FAILED: return { type: type, payload: payload, error: true };
        case TIMELINE_SELECTED: return { type: type, payload: payload };
        case TIMELINE_SAVE_SUCCESS: return { type: type, payload: payload };
        case UPDATE_SELECTED_TIMELINE: return { type: type, payload: payload };
        case TIMELINE_DUPLICATED: return { type: type, payload: payload };
        case TIMELINE_ITEM_CREATED: return { type: type, payload: payload };
        case TIMELINE_ITEM_REMOVED: return { type: type, payload: payload };
        case TIMELINE_ITEM_SELECTED: return { type: type, payload: payload };
        case ADD_TIMELINE_ITEM: return { type: type, payload: payload };
        case UPDATE_TIMELINE_ROW: return { type: type, payload: payload };
        case UPDATE_TIMELINE_ITEM: return { type: type, payload: payload };
        case UPDATE_TIMELINE_PROJECT_ITEM: return { type: type, payload: payload };
        case ASSIGN_TIMELINE_PROCEDURE: return { type: type, payload: payload };
        case DELETE_TIMELINE_ITEM: return { type: type, payload: payload };
        case TIMELINE_LIST_SORTED: return { type: type, payload: payload };
        case NEW_TIMELINE: return { type: type, payload: payload };
        case PROJECT_LIST_SORTED: return { type: type, payload: payload };
        default: return { type: type }
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
    const API_ENDPOINT = BASE_URI + BASE_API + 'getActiveProjects.view?';
    return (dispatch) => {
        dispatch(createAction(PROJECT_LIST_REQUESTED));
        fetch(API_ENDPOINT)
        .then(response => response.json())
        .then(data => { 
            if (data.success) dispatch(createAction(PROJECT_LIST_RECEIVED, data.rows));
            else dispatch(createAction(PROJECT_LIST_REQUEST_FAILED, null));
        })
        .catch((error) => dispatch(createAction(PROJECT_LIST_REQUEST_FAILED, error)));
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
            success: (results) => { dispatch(createAction(ANIMAL_LIST_RECEIVED, results.rows)) },
            failure: (error) => { dispatch(createAction(ANIMAL_LIST_REQUEST_FAILED, error)) }
        });
    };
}

export function fetchTimelinesByProject(objectid) {
    if (verboseOutput) console.log('fetchTimelinesByProject(' + objectid + ')');
    const API_ENDPOINT = BASE_URI + BASE_API + 'getActiveTimelines.view?projectObjectId=' + objectid
    return (dispatch) => {
        dispatch(createAction(TIMELINE_LIST_REQUESTED, {objectid} ));
        fetch(API_ENDPOINT)
        .then(response => response.json())
        .then(data => { if (data.success) dispatch(createAction(TIMELINE_LIST_RECEIVED, data.rows)); })
        .catch((error) => dispatch(createAction(TIMELINE_LIST_REQUEST_FAILED, error)));
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

export function selectProject(projectId, revision, objectid) {
    if (verboseOutput) console.log('selectProject(' + projectId + ',' + revision + ')');
    return (dispatch) => {
        dispatch(createAction(PROJECT_SELECTED, projectId));
        dispatch(fetchAnimalsByProject(projectId, revision));
        dispatch(fetchTimelinesByProject(objectid));
    }
}

export function selectTimeline(timeline) {
    if (verboseOutput) console.log('selectTimeline(' + timeline.TimelineId + ',' + timeline.RevisionNum + ')');
    return (dispatch) => {
        dispatch(createAction(TIMELINE_SELECTED, timeline));
    }    
}

export function duplicateTimeline(timeline) {
    if (verboseOutput) console.log('duplicateTimeline(' + timeline.TimelineId + ',' + timeline.RevisionNum + ')');
    return (dispatch) => {
        dispatch(createAction(TIMELINE_DUPLICATED, timeline));
    }   
}

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

export function updateTimelineItem(item) {
    if (verboseOutput) console.log('updateTimelineItem - Study Day: ' + item.StudyDay);
    return (dispatch) => {
        dispatch(createAction(UPDATE_TIMELINE_ITEM, item));
    }
}

export function updateSelectedTimeline(timeline) {
    if (verboseOutput) console.log('updateSelectedTimeline');
    return (dispatch) => {
        dispatch(createAction(UPDATE_SELECTED_TIMELINE, timeline));
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

export function newTimeline(timeline) {
    if (verboseOutput) console.log('NEW_TIMELINE');
    return (dispatch) => {
        dispatch(createAction(NEW_TIMELINE, timeline));
    }
}