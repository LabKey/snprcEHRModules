import React from 'react'
import ReactDOM from 'react-dom'
import { AppContainer } from 'react-hot-loader'

import SndEventsViewer from './SndEventsViewer'

const render = () => {
    ReactDOM.render(
      <AppContainer>
        <SndEventsViewer />
      </AppContainer>,
        document.getElementById('app')
    )
}

declare const module: any;
if (module.hot) {
    module.hot.accept()
}

render()
