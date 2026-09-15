import React from 'react'
import ReactDOM from 'react-dom'

import BiocontainmentObservationReview from './BiocontainmentObservationReview'

// Need to wait for container element to be available in labkey wrapper before render
window.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(<BiocontainmentObservationReview />, document.getElementById('app'))
})
