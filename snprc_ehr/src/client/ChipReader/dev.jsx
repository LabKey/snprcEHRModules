import React from 'react'
import ReactDOM from 'react-dom'
import { AppContainer } from 'react-hot-loader'

import ChipReader from './ChipReader'

const render = () => {
    ReactDOM.render(
      <AppContainer>
        <ChipReader />
      </AppContainer>,
        document.getElementById('app')
    )
}

if (module.hot) {
    module.hot.accept()
}

render()
