import React from 'react';
import ReactDOM from 'react-dom';
import { App } from '@labkey/api';

import {SndEventsWidget} from "../SndEventsWidget";

App.registerApp<any>('SndEventsWidgetWebpart', target => {
    ReactDOM.render(<SndEventsWidget />, document.getElementById(target));
});