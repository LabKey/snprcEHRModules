import React from 'react'
import ReactDOM from 'react-dom'
import { AppContainer } from 'react-hot-loader'

import SsrsReporting from './SsrsReporting'

const render = () => {
    ReactDOM.render(
      <AppContainer>
        <SsrsReporting />
      </AppContainer>,
        document.getElementById('app')
    )
}
declare const module: any;

if (module.hot) {
    module.hot.accept()
}

render()
