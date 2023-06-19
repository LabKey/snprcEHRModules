import React, { FC, useEffect } from 'react';
import { Provider } from 'react-redux';
import initializeStore from './store/initializeStore';
import { UIRouter } from './routers/UIRouter';
import { fetchProjects } from './actions/dataActions';

import './css/index.css';

// build the store and container
const store = initializeStore();

export const App: FC = () => {
    useEffect(() => {
        // ask the store to get the current projects
        store.dispatch(fetchProjects());
    }, []);

    return <Provider store={store}><UIRouter store={store} /></Provider>;
};
