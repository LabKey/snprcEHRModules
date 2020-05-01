import React from 'react'
import ReactDOM from 'react-dom'
import {AppContainer} from 'react-hot-loader'

import App from './HelloApp'

const render = () => {
    ReactDOM.render(
        <AppContainer>
            <App title={'Hello, World!'}/>
        </AppContainer>,
        document.getElementById('app')
    )
};

if (module.hot) {
    module.hot.accept();
}

render();