import React from 'react'
import ReactDOM from 'react-dom'
import { AppContainer } from 'react-hot-loader'

import BirthRecordReport from './BirthRecordReport'

const render = () => {
    ReactDOM.render(
      <AppContainer>
        <BirthRecordReport />
      </AppContainer>,
        document.getElementById('app')
    )
}

if (module.hot) {
    module.hot.accept()
}

render()
