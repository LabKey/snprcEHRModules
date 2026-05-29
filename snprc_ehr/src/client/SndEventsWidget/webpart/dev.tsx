/*
 * Copyright (c) 2023-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
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
        hasReadPermission: ctx.hasReadPermission ? ctx.hasReadPermission : undefined,
        hasWritePermission: ctx.hasWritePermission ? ctx.hasWritePermission : undefined
    }
    ReactDOM.render(
        <AppContainer>
            <SndEventsWidget {...config}/>
        </AppContainer>,
        document.getElementById(target)
    );
}, true /* hot */);

declare const module: any;