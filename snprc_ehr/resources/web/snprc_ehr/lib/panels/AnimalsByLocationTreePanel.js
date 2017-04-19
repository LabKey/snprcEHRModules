/**
 * Created by lkacimi on 4/11/2017.
 */
Ext4.define("AnimalsByLocationTreePanel", {
    extend: 'Ext.tree.Panel',
    store: Ext4.create('AnimalsByLocationTreeStore'),
    alias: 'widget.animals-by-location-tree-panel',
    id: 'locationsTree',
    rootVisible: false,
    styleHtmlContent: true,
    height: 600,
    width: 450,
    title: "Locations",
    initComponent: function () {
        this.getStore().load();
        this.callParent(arguments);
    }


});
