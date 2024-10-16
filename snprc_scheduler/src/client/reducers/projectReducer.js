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

export const verboseOutput = false;
const SEARCH_MODE_LABKEY = 1;
const SEARCH_MODE_SND = 2;
let SEARCH_MODE = SEARCH_MODE_SND;


import {
    ANIMAL_LIST_RECEIVED,
    ANIMAL_LIST_REQUEST_FAILED,
    PROJECT_LIST_RECEIVED,
    PROJECT_LIST_REQUEST_FAILED,
    PROJECT_SELECTED,
    PROJECT_LIST_FILTERED,
    ANIMAL_LIST_FILTERED,
    PROJECT_LIST_SORTED
} from "../actions/dataActions";

export const hasValue = (source, value) => {
    if (source == null) {
        source = '';
    }
    source = source.value ? source.value : source;
    source = (source + '').toUpperCase();
    return source.indexOf(value) > -1;

};

export default (state = { }, action) => {  
    let nextState = { ...state };
    let value = '';
    nextState.errors = [];
    switch (action.type) { 
        case PROJECT_LIST_RECEIVED:
            // action payload is the project array
            nextState.allProjects = action.payload;
            nextState.projects = action.payload;
            break;

        case PROJECT_LIST_REQUEST_FAILED:
            // action payload is the exception
            nextState.allProjects = [];
            nextState.projects = [];
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

        case PROJECT_LIST_SORTED:
            // action payload is an object containing the sort parameters { field: ?, direction: ? }
            if (action.payload.direction == "NONE") nextState.projects = nextState.allProjects;
            else {
                nextState.projects = _.sortBy(nextState.allProjects, action.payload.field);
                if (action.payload.direction == 'DESC') nextState.projects = nextState.projects.reverse();
            }
            break;
    };
    if (verboseOutput) {
        console.log('projectReducer() -> ' + action.type + '\nnext state:');
        console.log(nextState);  
    }     
    return nextState;
};

