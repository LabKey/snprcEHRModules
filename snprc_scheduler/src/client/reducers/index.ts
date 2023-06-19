import { combineReducers } from 'redux';

import rootReducer, { RootState } from './rootReducer';
import projectReducer, { ProjectState } from './projectReducer';
import timelineReducer, { TimelineState } from './timelineReducer';
import animalReducer, { AnimalState } from './animalReducer';

export interface AppState {
    animal: AnimalState;
    project: ProjectState;
    root: RootState;
    timeline: TimelineState;
}

export default combineReducers<AppState>({
    animal: animalReducer,
    project: projectReducer,
    root: rootReducer,
    timeline: timelineReducer,
});
