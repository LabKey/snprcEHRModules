/*
 * Copyright (c) 2023-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
import React from 'react';
import ReactDOM from 'react-dom';
import {SndEventsWidget} from "./SndEventsWidget";

const render = () => {
    const config = {filterConfig: [], hasReadPermission: true, hasWritePermission: true }
    ReactDOM.render(<SndEventsWidget {...config}/>, document.getElementById('app'))
};

render();
