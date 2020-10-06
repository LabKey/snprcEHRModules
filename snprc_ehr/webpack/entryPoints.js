/*
 * Copyright (c) 2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
module.exports = {
    apps: [{
        name: 'NewAnimalPage',
        title: 'New Animal Wizard',
        permission: 'read',
        path: './src/client/NewAnimalPage',
        scriptType: 'jsx'
    }, {
        name: 'BirthRecordReport',
        title: 'Birth Record Report',
        permission: 'read',
        path: './src/client/BirthRecordReport',
        scriptType: 'jsx'
    }, {
        name: 'ChipReader',
        title: 'Chip Reader',
        permission: 'read',
        path: './src/client/ChipReader',
        scriptType: 'jsx'
    },
    {
        name: 'SndEventsViewer',
        title: 'SND Events Viewer',
        permission: 'read',
        path: './src/client/SndEventsViewer',
        scriptType: 'jsx'
    },
    {
        name: 'SsrsReporting',
        title: 'PDF Reports',
        permission: 'read',
        path: './src/client/SsrsReporting',
        scriptType: 'tsx'
    }]
};
