import React from 'react';
import ReactDOM from 'react-dom';
import { AppContainer } from 'react-hot-loader';
import { App } from '@labkey/api';

import { SndEventsWidget } from "../SndEventsWidget";

App.registerApp<any>('SndEventsWidgetWebpart', (target: string, ctx) => {
    const config = {
        subjectID: ctx.subjectID ? JSON.parse(ctx.subjectID) : undefined
    }
    ReactDOM.render(
        <AppContainer>
            <SndEventsWidget {...config}/>
        </AppContainer>,
        document.getElementById(target)
    );
}, true /* hot */);

declare const module: any;