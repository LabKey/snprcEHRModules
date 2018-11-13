/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created by lkacimi on 4/13/2017.
 */
Ext4.define("InstitutionsStore", {
    extend: 'Ext.data.Store',
    model: "InstitutionModel",
    autoLoad: true,
    remoteSort: true,
    remoteFilter: true
});
