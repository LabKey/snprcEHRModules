/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created by lkacimi on 4/14/2017.
 */
Ext4.define("InstitutionWindow", {
    extend: "Ext.window.Window",
    modal: true,
    title: "Edit/Add Institution",
    width: 550,
    id: 'institution-window',
    resizable: false,
    items: [
        {
            xtype: 'institution-form-panel'
        }
    ]
});
