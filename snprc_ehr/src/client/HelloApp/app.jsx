import React from 'react'
import ReactDOM from 'react-dom'

import App from './HelloApp'

// Need to wait for container element to be available in labkey wrapper before render
window.addEventListener('DOMContentLoaded', (event) => {
    ReactDOM.render(<App title={'Hello, World!'}/>, document.getElementById('app'));
});
