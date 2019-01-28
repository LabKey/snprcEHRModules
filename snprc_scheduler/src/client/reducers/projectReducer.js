/* 
    ==================================================================================
    author:             David P. Smith
    email:              dsmith@txbiomed.org
    name:               snprc_scheduler
    description:        Animal procedure scheduling system     
    copyright:          Texas Biomedical Research Institute
    created:            October 3 2018      
    ==================================================================================
*/

import _ from 'lodash';

const verboseOutput = false;
const SEARCH_MODE_LABKEY = 1;
const SEARCH_MODE_SND = 2;
var SEARCH_MODE = SEARCH_MODE_SND;


import {
    ANIMAL_LIST_RECEIVED,
    ANIMAL_LIST_REQUEST_FAILED,
    PROJECT_LIST_RECEIVED,
    PROJECT_LIST_REQUEST_FAILED,
    PROJECT_SELECTED,
    PROJECT_LIST_FILTERED,
    ANIMAL_LIST_FILTERED,
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
    PROJECT_LIST_SORTED
} from "../actions/dataActions";

function hasValue (source, value)  {
    if (source == null) source = '';
    source = source.value ? source.value : source;
    source = (source + '').toUpperCase();
    if (source.indexOf(value) > -1) return true;
    return false;
};

function cloneTimeline(source) {
    let nt = Object.assign({ }, source);
    nt = Object.assign(nt, { TimelineId: -1, revisionNum: -1, IsDraft: true });
    
    
    
    //console.log('source object:');
    //console.log(source);
    //nt.TimelineId = -1;
    //nt.RevisionNum = -1;
    //nt.IsDraft = true;
    console.log('cloned object:');
    console.log(nt);
    return nt;
}

export default (state = { }, action) => {  
    let nextState = Object.assign({ }, state);
    let value = '';
    nextState.errors = [];
    switch (action.type) { 
        case PROJECT_LIST_RECEIVED:
            // action payload is the project array
            nextState.allProjects = action.payload;
            nextState.projects = action.payload;
            nextState.selectedProject = {};
            break;
        case ANIMAL_LIST_RECEIVED:
            // action payload is the animal array
            nextState.allAnimals = action.payload;
            nextState.animals = action.payload;
            break;
        case PROJECT_LIST_REQUEST_FAILED:
            // action payload is the exception
            nextState.allProjects = [];
            nextState.projects = [];
            nextState.errors.push(action.payload);
            break;
        case ANIMAL_LIST_REQUEST_FAILED:
            // action payload is the exception
            nextState.allAnimals = [];
            nextState.animals = [];
            nextState.errors.push(action.payload);
            break;
        case PROJECT_SELECTED:
            // action payload is the selected project ID
            nextState.projects.forEach((p) => {
                if (SEARCH_MODE == SEARCH_MODE_LABKEY) {
                    if (p.ProjectId.value == action.payload) nextState.selectedProject = p;
                } else if (SEARCH_MODE == SEARCH_MODE_SND) {
                    if (p.projectId.toString() == action.payload.toString()) 
                        nextState.selectedProject = p;
                }  
            })
            break;
        case PROJECT_LIST_FILTERED:
            // action payload is the filter value
            value = (action.payload + '').toUpperCase();
            if (value != '') {
                nextState.projects = [];
                nextState.allProjects.forEach((p) => {
                    switch(SEARCH_MODE) {
                        case SEARCH_MODE_LABKEY:
                            if (hasValue(p.Description, value) || hasValue(p.ProjectId, value) ||
                                hasValue(p.ChargeId, value) || hasValue(p.Iacuc, value) ||
                                hasValue(p.RevisionNum, value) || hasValue(p.StartDate, value) ||
                                hasValue(p.EndDate, value))
                            { nextState.projects.push(p); }
                            break;
                        case SEARCH_MODE_SND:
                            if (hasValue(p.description, value) || hasValue(p.Iacuc, value) ||
                                hasValue(p.CostAccount, value) || hasValue(p.referenceId, value) ||
                                hasValue(p.Veterinarian1, value) || hasValue(p.Veterinarian2, value) ||
                                hasValue(p.VsNumber, value) || hasValue(p.startDate, value) ||
                                hasValue(p.endDate, value)) 
                            { nextState.projects.push(p); }
                            break;
                    }
                });               
            } else nextState.projects = nextState.allProjects;
            break;
        case ANIMAL_LIST_FILTERED:
            // action payload is the filter value
            value = (action.payload + '').toUpperCase();
            if (value != '') {
                nextState.animals = [];
                nextState.allAnimals.forEach((a) => {
                    if (hasValue(a.Id, value) || hasValue(a.Age, value) || 
                        hasValue(a.Gender, value) || hasValue(a.Weight, value))
                    { nextState.animals.push(a); }
                })
            } else nextState.animals = nextState.allAnimals;
            break;
        case TIMELINE_LIST_RECEIVED:
            // action payload is the timeline array
            nextState.allTimelines = action.payload;
            nextState.timelines = action.payload;
            nextState.selectedTimeline = {};
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
            // add empty rows not saved
            for (const timelineItem of nextState.selectedTimeline.TimelineItems) {
                if (!timelineItem.ProjectItemId) {
                    action.payload.TimelineItems.push(timelineItem);
                }
            }
            nextState.selectedTimeline = action.payload;

            break;
        case ADD_TIMELINE_ITEM:
            // action payload is the timeline item
            nextState.selectedTimeline.TimelineItems.push(action.payload);
            break;
        case UPDATE_TIMELINE_ROW:
            // action payload is timeline item
            nextState.selectedTimeline.TimelineItems = nextState.selectedTimeline.TimelineItems.map(item => {
                if(action.payload.RowIdx === item.RowIdx) {
                    return { ...item, ...action.payload }
                }
                else return item;
            })

            break;
        case UPDATE_TIMELINE_ITEM:
            // action payload is timeline item
            nextState.selectedTimeline.TimelineItems = nextState.selectedTimeline.TimelineItems.map(item => {
                if((action.payload.ObjectId && (action.payload.ObjectId === item.ObjectId))
                    || (!action.payload.ObjectId && (action.payload.RowIdx === item.RowIdx) && (action.payload.ProjectItemId === item.ProjectItemId))) {
                    return { ...item, ...action.payload }
                }
                else return item;
            })

            break;
        case UPDATE_SELECTED_TIMELINE:

            nextState.selectedTimeline = {...nextState.selectedTimeline, ...action.payload};
            break;
        case ASSIGN_TIMELINE_PROCEDURE:

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

            break;
        case UPDATE_TIMELINE_PROJECT_ITEM:

            nextState.selectedTimeline.TimelineProjectItems = nextState.selectedTimeline.TimelineProjectItems.map(projItem => {

                if (projItem.ProjectItemId === action.payload.ProjectItemId) {
                    projItem = { ...projItem, ...action.payload }
                }

                return projItem;
            })

            break;
        case PROJECT_LIST_SORTED:
            // action payload is an object containing the sort parameters { field: ?, direction: ? }
            if (action.payload.direction == "NONE") nextState.projects = nextState.allProjects;
            else {
                nextState.projects = _.sortBy(nextState.allProjects, action.payload.field);
                if (action.payload.direction == 'DESC') nextState.projects = nextState.projects.reverse();
            }
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

            break;            
    };
    if (verboseOutput) {
        console.log('projectReducer() -> ' + action.type + '\nnext state:');
        console.log(nextState);  
    }     
    return nextState;
};

