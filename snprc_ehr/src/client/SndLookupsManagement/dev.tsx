/*
 * Copyright (c) 2023-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
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