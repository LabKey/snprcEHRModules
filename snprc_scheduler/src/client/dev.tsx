import React from 'react';
import { createRoot } from 'react-dom/client';
import './styles/css/index.scss';

import ProjectsView from './views/ProjectsView';
import { Provider } from 'react-redux';
import initializeStore from './store/initializeStore';
import { fetchProjects } from './actions/dataActions';

const store = initializeStore();
const appContainer = (
    <Provider store={store}>
        <ProjectsView store={store} />
        {/*<UIRouter store={store} />*/}
    </Provider>
);

store.dispatch(fetchProjects());

// Suppress ResizeObserver loop errors in development. This is only a development warning that is benign (but annoying)
// and does not affect the production build. Related to the resizing of react-data-grid.
const resizeObserverErrHandler = (e) => {
    if (e.message === 'ResizeObserver loop completed with undelivered notifications.') {
        const resizeObserverErr = document.getElementById('webpack-dev-server-client-overlay');
        if (resizeObserverErr) {
            resizeObserverErr.style.display = 'none';
        }
        e.stopImmediatePropagation();
    }
};

window.addEventListener('error', resizeObserverErrHandler);

const render = (): void => {
    createRoot(document.getElementById('app')).render(appContainer);
};

render();
