import React from 'react'
import ReactDOM from 'react-dom'

import BirthRecordReport from './BirthRecordReport'

// Need to wait for container element to be available in labkey wrapper before render
window.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(<BirthRecordReport />, document.getElementById('app'))
})
