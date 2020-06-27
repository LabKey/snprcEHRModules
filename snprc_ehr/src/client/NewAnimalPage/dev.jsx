import React from 'react'
import ReactDOM from 'react-dom'
import { AppContainer } from 'react-hot-loader'

import NewAnimalPage from './NewAnimalPage'

const render = () => {
    ReactDOM.render(
      <AppContainer>
        <NewAnimalPage />
      </AppContainer>,
        document.getElementById('app')
    )
}

if (module.hot) {
    module.hot.accept()
}

render()
