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
        path: './src/client/NewAnimalPage'
    }, {
        name: 'BirthRecordReport',
        title: 'Birth Record Report',
        permission: 'read',
        path: './src/client/BirthRecordReport'
    }, {
        name: 'ChipReader',
        title: 'Chip Reader',
        permission: 'read',
        path: './src/client/ChipReader'
    },
        {
            name: 'SsrsReporting',
            title: 'PDF Reports',
            permission: 'read',
            path: './src/client/SsrsReporting'
        }]
};