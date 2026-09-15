import React from 'react'
import ReactDOM from 'react-dom'
import { AppContainer } from 'react-hot-loader'

import BiocontainmentObservationReview from './BiocontainmentObservationReview'

const render = () => {
    ReactDOM.render(
      <AppContainer>
        <BiocontainmentObservationReview />
      </AppContainer>,
        document.getElementById('app')
    )
}
declare const module: any;

if (module.hot) {
    module.hot.accept()
}

render()
