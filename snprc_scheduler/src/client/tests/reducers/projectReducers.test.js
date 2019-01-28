import projectReducer from '../../reducers/projectReducer';
import {projectData} from '../fixtures/projectData';
import {animalData} from '../fixtures/animalData';
import {timelineData} from "../fixtures/timelineData";

import {
    ANIMAL_LIST_FILTERED,
    ANIMAL_LIST_RECEIVED,
    ANIMAL_LIST_REQUEST_FAILED,
    PROJECT_LIST_FILTERED,
    PROJECT_LIST_RECEIVED,
    PROJECT_LIST_REQUEST_FAILED,
    PROJECT_LIST_SORTED,
    PROJECT_SELECTED,
    TIMELINE_DUPLICATED,
    TIMELINE_LIST_RECEIVED,
    TIMELINE_SELECTED
} from "../../actions/dataActions";

let projectState = {
    0: projectData[0],
    1: projectData[1],
    errors: [],
    allProjects: [...projectData] ,
    projects: [...projectData]
};

const animalState = {
    0: animalData[0],
    1: animalData[1],
    2: animalData[2],
    errors: [],
    allAnimals: [...animalData],
    animals: [...animalData]
};

const timelineState = {
    0: timelineData[0],
    1: timelineData[1],
    errors: [],
    allTimelines: [...timelineData],
    timelines: [...timelineData]
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
                    ...projectState,
                    "selectedProject": {}
            });
});

test('Should set animal list', () => {
    const action = {
        type: ANIMAL_LIST_RECEIVED,
        payload: animalData
    };
    const state = projectReducer(animalData, action);
    expect(state).toEqual(
            {
                    ...animalState
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

test('Should not assign animals when an error occurs', () => {
    const action = {
        type: ANIMAL_LIST_REQUEST_FAILED,
        payload: {}
    };
    const state = projectReducer(animalData, action);
    expect(state).toEqual(
            {
                ...animalState,
                errors: [{}],
                allAnimals: [],
                animals: []
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

test('Should select animal using filter (test id & gender)', () => {
    // search by id
    let action = {
        type: ANIMAL_LIST_FILTERED,
        payload: animalData[0].Id.value
    };
    let state = projectReducer(animalState, action);
    expect(state).toEqual(
            {
                ...animalState,
                animals: [animalData[0]]
            });

    // search by gender
    action = {
        type: ANIMAL_LIST_FILTERED,
        payload: 'M'
    };
    state = projectReducer(animalState, action);
    expect(state).toEqual(
            {
                ...animalState,
                animals: [animalData[1], animalData[2]]
            });

});

test('Should set timeline list', () => {
    const action = {
        type: TIMELINE_LIST_RECEIVED,
        payload: timelineData
    };
    const state = projectReducer(timelineData, action);
    expect(state).toEqual(
            {
                    ...timelineState,
                    "selectedTimeline": {}

            });
});

test('Should clone timeline returning a new timeline object with TimelineId = -1, revisionNum = -1, IsDraft = true', () => {
    const action = {
        type: TIMELINE_DUPLICATED,
        payload: timelineData[0]
    };
    const state = projectReducer(timelineState, action);
    expect(state).toEqual(
            {
                ...timelineState,
                timelines: [ ...timelineData, {...timelineData[0], TimelineId: -1, revisionNum: -1, IsDraft: true} ]

            });
});


test('Should select timeline', () => {
    const action = {
        type: TIMELINE_SELECTED,
        payload: timelineData[0]
    };
    const state = projectReducer(timelineState, action);
    expect(state).toEqual(
            {
                ...timelineState,
                selectedTimeline: timelineData[0]
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

