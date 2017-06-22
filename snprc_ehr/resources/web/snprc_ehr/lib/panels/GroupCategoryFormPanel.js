/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define('GroupCategoryFormPanel', {
    extend: "Ext.form.Panel",
    alias: "widget.group-category-form-panel",
    id: 'group-category-form-panel',
    bodyStyle: 'padding:5px 5px 0',
    labelWidth: 300,
    defaults: {width: 445},

    items: [
        {
            xtype: 'textfield',
            name: 'categoryCode',
            fieldLabel: 'Code',
            disabled: true
        },
        {
            xtype: 'textfield',
            name: 'description',
            fieldLabel: 'Description',
            allowBlank: false
        },
        {
            xtype: 'textarea',
            name: 'comment',
            fieldLabel: 'Comment'
        },
        {
            xtype: 'combo',
            fieldLabel: 'Displayable',
            name: 'displayable',
            store: Ext4.create('YesNoStore'),
            valueField: 'value',
            displayField: 'text',
            editable: false,
            allowBlank: false
        },
        {
            xtype: 'combo',
            fieldLabel: 'Species',
            name: 'species',
            store: Ext4.create('SpeciesStore'),
            valueField: 'arcSpeciesCode',
            displayField: 'speciesName',
            typeAhead: true,
            queryMode: 'local'

        },
        {
            xtype: 'combo',
            fieldLabel: 'Sex',
            name: 'sex',
            store: Ext4.create('GenderStore'),
            valueField: 'value',
            displayField: 'text',
            editable: false
        },
        {
            xtype: 'combo',
            fieldLabel: 'Enforce Exclusivity',
            name: 'enforceExclusivity',
            store: Ext4.create('YesNoStore'),
            valueField: 'value',
            displayField: 'text',
            editable: false,
            allowBlank: false
        },
        {
            xtype: 'combo',
            fieldLabel: 'Allow Future Date',
            name: 'allowFutureDate',
            store: Ext4.create('YesNoStore'),
            valueField: 'value',
            displayField: 'text',
            editable: false,
            allowBlank: false
        },
        {
            xtype: 'numberfield',
            fieldLabel: 'Sort Order',
            name: 'sortOrder',
            stepValue: 1
        }

    ],
    buttons: [
        {
            text: 'Submit',
            handler: function () {

                this.up('form').updateRecord(this.up('form').getRecord());
                if (!this.up('form').isValid()) {
                    return;
                }

                this.up('form').getRecord().save({
                    callback: function (record, response) {
                        if (response.success) {
                            Ext4.getCmp('group-categories-grid-panel').getStore().load({
                                callback: function () {
                                    Ext4.getCmp('group-categories-grid-panel').getSelectionModel().select(0);

                                }
                            });
                        }
                        else {
                            Ext4.MessageBox.alert('Something went wrong', 'Unable to update the record');
                        }

                    }
                });

            }
        }
    ]
});
