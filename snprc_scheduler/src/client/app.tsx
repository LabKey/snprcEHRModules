// import React
import React from 'react';
import { createRoot } from 'react-dom/client';
import './styles/css/index.scss';

// import Redux and our store
import { Provider } from 'react-redux';
import initializeStore from './store/initializeStore';

// import routing
import ProjectsView from './views/ProjectsView';
import { fetchProjects } from './actions/dataActions';

// build the store and container
const store = initializeStore();
const appContainer = (
    <Provider store={store}>
        <ProjectsView store={store} />
    </Provider>
);

// ask the store to get the current projects
store.dispatch(fetchProjects());

// Need to wait for the container element to be available in the labkey wrapper before render
window.addEventListener('DOMContentLoaded', event => {
    createRoot(document.getElementById('app')).render(appContainer);
});
