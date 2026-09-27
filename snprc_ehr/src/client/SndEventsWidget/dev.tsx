import React from 'react';
import ReactDOM from 'react-dom';
import {SndEventsWidget} from "./SndEventsWidget";

const render = () => {
    const config = {filterConfig: [], hasReadPermission: true, hasWritePermission: true }
    ReactDOM.render(<SndEventsWidget {...config}/>, document.getElementById('app'))
};

render();
