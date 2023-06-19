import projectReducer from '../../reducers/projectReducer';
import { projectData } from '../fixtures/projectData';

import {
    PROJECT_LIST_FILTERED,
    PROJECT_LIST_RECEIVED,
    PROJECT_LIST_REQUEST_FAILED,
    PROJECT_LIST_SORTED,
    PROJECT_SELECTED
} from "../../actions/dataActions";

let projectState = {
    0: projectData[0],
    1: projectData[1],
    errors: [],
    allProjects: [...projectData] ,
    projects: [...projectData]
};

test('make sure default state gets returns an empty error array.', () => {
    const state = projectReducer(undefined, {type: '@@init'});
    expect(state).toEqual({"errors": []});
});

test('Should set project list', () => {
    const action = {
        type: PROJECT_LIST_RECEIVED,
        payload: projectData
    };
    const state = projectReducer(projectData, action);
    expect(state).toEqual(
            {
                    ...projectState
            });
});

test('Should not assign projects when an error occurs', () => {
    const action = {
        type: PROJECT_LIST_REQUEST_FAILED,
        payload: {}
    };
    const state = projectReducer(projectData, action);
    expect(state).toEqual(
            {
               ...projectState,
                errors: [{}],
                allProjects: [],
                projects: []
            });
});

test('Should select project - SEARCH_MODE == SEARCH_MODE_SND', () => {
    const action = {
        type: PROJECT_SELECTED,
        payload: projectData[0].projectId
    };
    const state = projectReducer(projectState, action);
    expect(state).toEqual(
            {
                ...projectState,
                selectedProject: projectData[0]
            });
});

test('Should select project using filter', () => {
    const action = {
        type: PROJECT_LIST_FILTERED,
        payload: projectData[0].description
    };
    const state = projectReducer(projectState, action);
    expect(state).toEqual(
            {
               ...projectState,
                projects : [projectData[0]]
            });
});

test('Should do a descending sort on project data', () => {
    const action = {
        type: PROJECT_LIST_SORTED,
        payload: {direction: "DESC", field: "projectId"}
    };
    const state = projectReducer(projectState, action);
    expect(state).toEqual(
            {
                ...projectState,
                projects: [projectData[1], projectData[0]]
            });
});

