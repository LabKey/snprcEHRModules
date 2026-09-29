/*
 * Copyright (c) 2023-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
import React from 'react';
import ReactDOM from 'react-dom';

import SndLookupsManagement from './SndLookupsManagement';

const render = () => {
    ReactDOM.render(<SndLookupsManagement />, document.getElementById('app'));
};

render();
