import React from 'react';
import ReactDOM from 'react-dom';
import { AppContainer } from 'react-hot-loader';

import SndLookupsManagement from './SndLookupsManagement';

const render = () => {
    ReactDOM.render(
        <AppContainer>
            <SndLookupsManagement />
        </AppContainer>,
        document.getElementById('app')
    );
};
declare const module: any;

if (module.hot) {
    module.hot.accept();
}

render();