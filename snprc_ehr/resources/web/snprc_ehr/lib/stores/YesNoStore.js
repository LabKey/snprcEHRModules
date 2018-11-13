/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define("YesNoStore", {
    extend: 'Ext.data.SimpleStore',
    data: [
        ['Y', 'Yes'],
        ['N', 'No']
    ],
    id: 0,
    fields: ['value', 'text']
});