import React from 'react'
import ReactDOM from 'react-dom'

import SsrsReporting from './SsrsReporting'

// Need to wait for container element to be available in labkey wrapper before render
window.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(<SsrsReporting />, document.getElementById('app'))
})
