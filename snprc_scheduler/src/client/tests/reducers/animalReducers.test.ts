import {
    ANIMAL_LIST_RECEIVED,
    ANIMAL_LIST_REQUEST_FAILED,
    AVAILABLE_ANIMAL_LIST_FILTERED
} from '../../actions/dataActions';
import { animalData } from '../fixtures/animalData';
import projectReducer from '../../reducers/projectReducer';

const animalState = {
    0: animalData[0],
    1: animalData[1],
    2: animalData[2],
    errors: []
};

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

test('Should not assign animals when an error occurs', () => {
    const action = {
        type: ANIMAL_LIST_REQUEST_FAILED,
        payload: {}
    };
    const state = projectReducer(animalData, action);
    expect(state).toEqual(
            {
                ...animalState,
                errors: []
            });
});

test('Should select animal using filter (test id & gender)', () => {
    // search by id
    let action = {
        type: AVAILABLE_ANIMAL_LIST_FILTERED,
        payload: animalData[0].Id.value
    };
    let state = projectReducer(animalState, action);
    expect(state).toEqual(
            {
                ...animalState
            });

    // search by gender
    action = {
        type: AVAILABLE_ANIMAL_LIST_FILTERED,
        payload: 'M'
    };
    state = projectReducer(animalState, action);
    expect(state).toEqual(
            {
                ...animalState
            });

});
