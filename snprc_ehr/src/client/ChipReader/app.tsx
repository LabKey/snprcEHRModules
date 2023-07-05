import React from 'react'
import ReactDOM from 'react-dom'

import ChipReader from './ChipReader.jsx'

// Need to wait for container element to be available in labkey wrapper before render
window.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(<ChipReader />, document.getElementById('app'))
})
