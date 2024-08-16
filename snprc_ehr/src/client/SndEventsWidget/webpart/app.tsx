import React from 'react';
import ReactDOM from 'react-dom';
import { App } from '@labkey/api';

import {SndEventsWidget} from "../SndEventsWidget";
import { configProps } from './config';


App.registerApp<any>('SndEventsWidgetWebpart', (target, ctx) => {
    const config: configProps = {
        ...ctx,
        filterConfig: ctx.filterConfig ? JSON.parse(ctx.filterConfig) : undefined,
        hasReadPermission: ctx.hasReadPermission ? JSON.parse(ctx.hasReadPermission) : undefined,
        hasWritePermission: ctx.hasWritePermission ? JSON.parse(ctx.hasWritePermission) : undefined,
    }
    ReactDOM.render(<SndEventsWidget {...config} />, document.getElementById(target));
});