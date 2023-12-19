import React from 'react';
import ReactDOM from 'react-dom';
import { AppContainer } from 'react-hot-loader';
import { App } from '@labkey/api';

import { SndEventsWidget } from "../SndEventsWidget";
import { configProps } from './config';

App.registerApp<any>('SndEventsWidgetWebpart', (target: string, ctx) => {
    const config: configProps = {
        ...ctx,
        filterConfig: ctx.filterConfig ? JSON.parse(ctx.filterConfig) : undefined,
        hasPermission: ctx.hasPermission ? ctx.hasPermission : undefined
    }
    ReactDOM.render(
        <AppContainer>
            <SndEventsWidget {...config}/>
        </AppContainer>,
        document.getElementById(target)
    );
}, true /* hot */);

declare const module: any;