/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
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
