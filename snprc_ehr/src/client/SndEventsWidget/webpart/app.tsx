import React from 'react';
import ReactDOM from 'react-dom';
import { App } from '@labkey/api';

import {SndEventsWidget} from "../SndEventsWidget";


App.registerApp<any>('SndEventsWidgetWebpart', (target, ctx) => {
    const config = {
        subjectID: ctx.subjectID ? JSON.parse(ctx.subjectID) : undefined
    }
    ReactDOM.render(<SndEventsWidget {...config} />, document.getElementById(target));
});