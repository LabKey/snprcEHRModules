import React from 'react';
import ReactDOM from 'react-dom';
import { AppContainer } from 'react-hot-loader';
import {SndEventsWidget} from "./SndEventsWidget";

const render = () => {
    const config = {filterConfig: [], hasReadPermission: true, hasWritePermission: true }
    ReactDOM.render(
        <AppContainer>
            <SndEventsWidget {...config}/>
        </AppContainer>,
        document.getElementById('app')
    )
};

declare const module: any;

if (module.hot) {
    module.hot.accept();
}

render();