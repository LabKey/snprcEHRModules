/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define("GroupMembersStore", {
    extend: 'Ext.data.Store',
    autoLoad: false,
    model: "GroupMemberModel",

    setGroup: function (group) {
        this.group = group;
    },
    getGroup: function () {
        return this.group || null;
    }

});