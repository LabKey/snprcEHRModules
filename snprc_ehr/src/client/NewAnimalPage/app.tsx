import React from 'react'
import ReactDOM from 'react-dom'

import NewAnimalPage from './NewAnimalPage'

// Need to wait for container element to be available in labkey wrapper before render
window.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(<NewAnimalPage />, document.getElementById('app'))
})
