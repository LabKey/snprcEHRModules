import React from 'react';
import ReactDOM from 'react-dom';
import {SndEventsWidget} from "./SndEventsWidget";

// Need to wait for container element to be available in labkey wrapper before render
window.addEventListener('DOMContentLoaded', (event) => {
    const config = {filterConfig: []}
    ReactDOM.render(<SndEventsWidget {...config} />, document.getElementById('app'));
});