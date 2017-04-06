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