import React from 'react';
import ReactDOM from 'react-dom';
import { SndLookupsManagement } from './SndLookupsManagement';

// Need to wait for container element to be available in labkey wrapper before render
window.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(<SndLookupsManagement/>, document.getElementById('app'));
});