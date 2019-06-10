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

// import React
import * as React from 'react';
import ReactDOM from 'react-dom'

// import Redux
import { createStore, combineReducers, applyMiddleware, compose } from 'redux';
import ReduxThunk from 'redux-thunk';

// import reducers
import rootReducer from '../reducers/rootReducer';
import projectReducer from '../reducers/projectReducer';
import timelineReducer from "../reducers/timelineReducer";
import animalReducer from "../reducers/animalReducer";

// enable redux developer tools  
const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;

export default () => {
    // Store creation
    const store = createStore(
        combineReducers({
            project: projectReducer,
            timeline: timelineReducer,
            animal: animalReducer,
            root: rootReducer
        }),
        composeEnhancers(applyMiddleware(ReduxThunk))
        //,window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__()
    );
    
    return store;
};