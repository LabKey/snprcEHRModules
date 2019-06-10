import {hasValue, verboseOutput} from "./projectReducer";
import {
    ANIMAL_ASSIGNED,
    ANIMAL_LIST_FILTERED,
    ANIMAL_LIST_RECEIVED,
    ANIMAL_LIST_REQUEST_FAILED, ASSIGNED_ANIMAL_LIST_FILTERED,
    AVAILABLE_ANIMAL_LIST_FILTERED, UPDATE_ASSIGNED_ANIMALS
} from "../actions/dataActions";


export default (state = { }, action) => {
    let nextState = { ...state };
    nextState.errors = [];
    switch (action.type) {
        case ANIMAL_LIST_RECEIVED:
            // action payload is the animal array
            nextState.allAnimals = action.payload.map((row) => {
                let newRow = {};
                for (let [key, value] of Object.entries(row)) {
                    newRow[key] = value.value;
                }
                newRow.assigned = false;
                return newRow;
            });
            nextState.availableAnimals = nextState.allAnimals.map(row => {return row});
            nextState.assignedAnimals = [];
            break;
        case ANIMAL_LIST_REQUEST_FAILED:
            // action payload is the exception
            nextState.allAnimals = [];
            nextState.availableAnimals = [];
            nextState.assignedAnimals = [];
            nextState.errors.push(action.payload);
            break;
        case ANIMAL_ASSIGNED:
            // action payload is the exception
            nextState.availableAnimals = [];
            nextState.errors.push(action.payload);
            break;
        case UPDATE_ASSIGNED_ANIMALS:
            // action payload is the timelineAnimalItems
            nextState.assignedAnimals = [];
            nextState.availableAnimals = [];
            nextState.allAnimals.forEach(animal => {
                const assigned = action.payload.find(item => {
                    return item.AnimalId === animal.Id && !item.IsDeleted;
                })

                if (assigned) {
                    nextState.assignedAnimals.push({...animal, EndDate: assigned.EndDate});
                    animal.assigned = true;
                }
                else {
                    nextState.availableAnimals.push({...animal});
                }
            })
            break;
        case AVAILABLE_ANIMAL_LIST_FILTERED:
            // action payload is the filter value
            const value = (action.payload + '').toUpperCase();
            nextState.availableAnimals = nextState.allAnimals.filter((animal) => {
                if (value !== '') {
                    return (!animal.assigned && hasValue(animal.Id, value))
                }
                else {
                    return (!animal.assigned)
                }

            })
            break;
        case ASSIGNED_ANIMAL_LIST_FILTERED:
            // action payload is the filter value
            const search = (action.payload + '').toUpperCase();
            nextState.assignedAnimals = nextState.allAnimals.filter((animal) => {
                if (search !== '') {
                    return (animal.assigned && hasValue(animal.Id, search))
                }
                else {
                    return (animal.assigned);
                }
            });
            break;
    }
    if (verboseOutput) {
        console.log('animalReducer() -> ' + action.type + '\nnext state:');
        console.log(nextState);
    }
    return nextState;
};