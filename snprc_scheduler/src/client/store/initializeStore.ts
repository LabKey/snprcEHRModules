// import Redux
import { applyMiddleware, combineReducers, compose, createStore, Store } from 'redux';
import { thunk } from 'redux-thunk';

// import reducers
import rootReducer from '../reducers/rootReducer';
import projectReducer from '../reducers/projectReducer';
import timelineReducer from '../reducers/timelineReducer';
import animalReducer from '../reducers/animalReducer';

// enable redux developer tools
declare global {
    interface Window {
        __REDUX_DEVTOOLS_EXTENSION_COMPOSE__?: typeof compose;
    }
}

const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;

export default (): Store => {
    // Store creation
    const store = createStore(
        combineReducers({
            project: projectReducer,
            timeline: timelineReducer,
            animal: animalReducer,
            root: rootReducer,
        }),
        composeEnhancers(applyMiddleware(thunk))
    );

    return store;
};
