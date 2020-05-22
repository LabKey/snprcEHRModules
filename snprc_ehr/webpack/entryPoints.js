/*
 * Copyright (c) 2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
module.exports = {
    apps: [{
        name: 'helloWorld',
        title: 'Hello World Page',
        permission: 'read',
        path: './src/client/HelloWorldPage',
        scriptType: 'tsx'
    }
    ,{
        name: 'HelloApp',
        title: 'Hello App Page',
        permission: 'read',
        path: './src/client/HelloApp',
        scriptType: 'jsx'
    }
    ,{
        name: 'NewAnimalPage',
        title: 'New Animal Wizard',
        permission: 'read',
        path: './src/client/NewAnimalPage',
        scriptType: 'jsx'
    }
    ]
};