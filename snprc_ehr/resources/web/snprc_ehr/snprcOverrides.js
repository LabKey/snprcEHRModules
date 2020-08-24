/*
 * Copyright (c) 2015-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.namespace('SNPRC_EHR');

LDK.Utils.splitIds = function (subjects, unsorted) {
    subjects = Ext4.String.trim(subjects);

    // Expand "X..Y" into X, X+1, X+2, ..., Y
    if (subjects.match(/[0-9]+\.\.[0-9]+/)) {
        var sections = subjects.split("..");
        if (sections.length == 2) {
            var num1 = parseInt(sections[0]);
            var num2 = parseInt(sections[1]);
            var start = Math.min(num1, num2);
            var end = Math.max(num1, num2);

            var result = [];
            for (var x = start; x <= end; x++) {
                result.push(x);
            }
            return result;
        }
    }

    // Replace IDs of the form "1 2345" with "1_2345"
    subjects = subjects.replace(/([0-9])( )([0-9][0-9][0-9][0-9])/g, '$1_$3');
    // All other whitespace gets trimmed
    subjects = subjects.replace(/[\s,;]+/g, ';');
    subjects = subjects.replace(/(^;|;$)/g, '');

    // SNPRC identifiers use upper case characters
    subjects = subjects.toUpperCase();

    if (subjects) {
        var result = subjects.split(';');
        result = Ext4.unique(result);
        if (!unsorted) {
            result = result.sort();
        }
        return result;
    }
    else
        return [];
};


Ext4.override(EHR.panel.SnapshotPanel, {
    appendParentageResults: function (toSet, results) {

        if (results) {
            var parentMap = {};
            Ext4.each(results, function (row) {
                var parent = row.parent;
                var relationship = row.relationship;

                if (parent && relationship) {
                    var text = relationship + ' - ' + parent;

                    if (!parentMap[text])
                        parentMap[text] = [];

                    var method = row.method;
                    if (method) {
                        parentMap[text].push(method);
                    }
                }
            }, this);

            var values = [];
            Ext4.Array.forEach(Ext4.Object.getKeys(parentMap).sort(), function (text) {
                parentMap[text] = Ext4.unique(parentMap[text]);
                var method = parentMap[text].join(', ');
                values.push('<a href="' + LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {
                    schemaName: 'study',
                    'query.queryName': 'demographicsParentStatus',
                    'query.Id~eq': this.subjectId
                }) + '" target="_blank">' + text + (method ? ' (' + method + ')' : '') + '</a>');
            }, this);

            if (values.length)
                toSet['parents'] = values.join('<br>');
        }
        else {
            toSet['parents'] = 'No data';
        }


    },

    appendIdHistoryResults: function (toSet, results) {
        var text = [];
        if (results) {
            var rows = [];
            Ext4.each(results, function (row) {
                var newRow = {
                    id_value: row['value'],
                    id_type: row['id_type/description']
                };
                rows.push(newRow);
            }, this);

            Ext4.each(rows, function (r) {
                text.push('<tr><td nowrap>' + r.id_type + ':' + '</td><td style="padding-left: 5px;" nowrap>' + r.id_value + '</td></tr>');
            }, this);
        }

        toSet['idHistories'] = text.length ? '<table>' + text.join('') + '</table>' : null;
    },


    appendCurrentAccountsResults: function (toSet, results) {
        var text = [];
        if (results) {
            var rows = [];
            Ext4.each(results, function (row) {
                var newRow = {
                    account_date: row['date'],
                    account: row['account'],
                };
                rows.push(newRow);
            }, this);

            Ext4.each(rows, function (r) {
                var d = LDK.ConvertUtils.parseDate(r.account_date, LABKEY.extDefaultDateFormat);
                text.push('<tr><td nowrap>' + Ext4.Date.format(d, LABKEY.extDefaultDateFormat) +
                        '</td><td style="padding-left: 5px;" nowrap>' + r.account + '</td></tr>');
            }, this);
        }

        toSet['currentAccounts'] = text.length ? '<table>' + text.join('') + '</table>' : null;
    },


    appendCases: function (toSet, results) {
        var text = [];
        if (results) {
            var rows = [];
            Ext4.each(results, function (row) {
                var newRow = {
                    admit_date: row['date'],
                    admit_complaint: row['admitcomplaint'],
                };
                rows.push(newRow);
            }, this);

            Ext4.each(rows, function (r) {
                var d = LDK.ConvertUtils.parseDate(r.admit_date, LABKEY.extDefaultDateFormat);
                text.push(Ext4.Date.format(d, LABKEY.extDefaultDateFormat) + ' ' + r.admit_complaint);
            }, this);
        }

        toSet['activeCases'] = text.length ? text.join(',<br>') : 'None';
    },

    appendCurrentPedigreeResults: function (toSet, results) {
        var text = [];
        if (results) {
            var rows = [];
            Ext4.each(results, function (row) {
                var newRow = {
                    pedigree_date: row['date'],
                    pedigree: row['pedigree'],
                };
                rows.push(newRow);
            }, this);

            Ext4.each(rows, function (r) {
                var d = LDK.ConvertUtils.parseDate(r.pedigree_date, LABKEY.extDefaultDateFormat);
                text.push('<tr><td nowrap>' + Ext4.Date.format(d, LABKEY.extDefaultDateFormat) +
                        '</td><td style="padding-left: 5px;" nowrap>' + r.pedigree + '</td></tr>');
            }, this);
        }

        toSet['currentPedigree'] = text.length ? '<table>' + text.join('') + '</table>' : 'N/A';
    },

    appendCurrentDietResults: function (toSet, results) {
        var text = [];
        if (results) {
            var rows = [];
            Ext4.each(results, function (row) {
                var newRow = {
                    diet_date: row['date'],
                    diet: row['code/meaning'],
                };
                rows.push(newRow);
            }, this);

            Ext4.each(rows, function (r) {
                var d = LDK.ConvertUtils.parseDate(r.diet_date, LABKEY.extDefaultDateFormat);
                text.push('<tr><td nowrap>' + Ext4.Date.format(d, LABKEY.extDefaultDateFormat) +
                        '</td><td style="padding-left: 5px;" nowrap>' + r.diet + '</td></tr>');
            }, this);
        }

        toSet['currentDiet'] = text.length ? '<table>' + text.join('') + '</table>' : 'None';
    },

    appendGroups: function (toSet, results) {

        var values = [];
        if (results) {
            Ext4.each(results, function (row) {

                if (row['groupId/category_code/description'] === null) {
                    values.push(row['groupId/name']);
                }
                else {
                    values.push(row['groupId/category_code/description'] + ': ' + row['groupId/name']);
                }
            }, this);
        }

        toSet['groups'] = values.length ? values.join('<br>') : 'None';
    },

    appendAssignments: function (toSet, results) {
        toSet['assignments'] = null;

        if (this.redacted) {
            return;
        }

        var values = [];
        if (results) {
            Ext4.each(results, function (row) {
                var val = row['protocol/displayName'] || ' ';
                val += ' [' + row['protocol/inves'] + ']';
                // val += ' [' + row['protocol/title'] + ']';

                if (val)
                    values.push(val);
            }, this);
        }

        toSet['assignments'] = values.length ? values.join('<br>') : 'None';
    },

    getBaseItems: function () {
        return [{
            xtype: 'container',
            border: false,
            defaults: {
                border: false
            },
            items: [{
                xtype: 'container',
                html: '<b>Summary:</b><hr>'
            }, {
                bodyStyle: 'padding: 5px;',
                layout: 'column',
                defaults: {
                    border: false
                },
                items: [{
                    xtype: 'container',
                    columnWidth: 0.25,
                    defaults: {
                        labelWidth: this.defaultLabelWidth,
                        style: 'margin-right: 20px;'
                    },
                    items: [{
                        xtype: 'displayfield',
                        fieldLabel: 'Location',
                        //width: 420,
                        name: 'location'
                    }, {
                        xtype: 'displayfield',
                        hidden: this.redacted,
                        name: 'assignments',
                        fieldLabel: 'IACUC Assignments'
                    }, {
                        xtype: 'displayfield',
                        fieldLabel: 'Groups',
                        hidden: this.redacted,
                        name: 'groups'
                    }, {
                        xtype: 'displayfield',
                        fieldLabel: 'Open Admissions',
                        name: 'activeCases'
                    }, {
                        xtype: 'displayfield',
                        fieldLabel: 'Current Account',
                        name: 'currentAccounts'
                    }]
                }, {
                    xtype: 'container',
                    columnWidth: 0.25,
                    defaults: {
                        labelWidth: this.defaultLabelWidth,
                        style: 'margin-right: 20px;'
                    },
                    items: [{
                        xtype: 'displayfield',
                        fieldLabel: 'Status',
                        name: 'calculated_status'
                    }, {
                        xtype: 'displayfield',
                        fieldLabel: 'Gender',
                        name: 'gender'
                    }, {
                        xtype: 'displayfield',
                        fieldLabel: 'Species',
                        name: 'species'
                    }, {
                        xtype: 'displayfield',
                        fieldLabel: 'Age',
                        name: 'age'
                    }, {
                        xtype: 'displayfield',
                        fieldLabel: 'Current Diet',
                        name: 'currentDiet'
                    }]
                }, {
                    xtype: 'container',
                    columnWidth: 0.35,
                    defaults: {
                        labelWidth: this.defaultLabelWidth,
                        style: 'margin-right: 20px;'
                    },
                    items: [{
                        xtype: 'displayfield',
                        fieldLabel: 'Flags',
                        name: 'flags'
                    }, {
                        xtype: 'displayfield',
                        fieldLabel: 'Last TB Date',
                        name: 'lastTB'
                    }, {
                        xtype: 'displayfield',
                        fieldLabel: 'Weights',
                        name: 'weights'
                    }, {
                        xtype: 'displayfield',
                        fieldLabel: 'Id History',
                        name: 'idHistories'
                    }]
                }]
            }]
        }];
    },
    appendMhcSummary: function (toSet, results) {
        if (results) {
            toSet['mhcSummary'] = '<a onclick="SNPRC_EHR.Utils.showMhcPopup(\'' + LABKEY.Utils.encodeHtml(this.subjectId) + '\', this);">' +  LABKEY.Utils.encodeHtml(results[0].mhcSummary)
        }
        else {
            toSet['mhcSummary'] = ''
        }
    }, appendFlags: function(toSet, results){
        var values = [];
        if (results){
            Ext4.each(results, function(row){
                var category = row['flag/category'];
                var highlight = row['flag/category/doHighlight'];
                var omit = row['flag/category/omitFromOverview'];

                //skip
                if (omit === true)
                    return;

                if (category)
                    category = Ext4.String.trim(category);

                var val = LABKEY.Utils.encodeHtml(this.getFlagDisplayValue(row));
                var text = val;
                if (category)
                    text = LABKEY.Utils.encodeHtml(category) + ': ' + val;

                if (text && highlight)
                    text = '<span style="background-color:yellow">' + text + '</span>';

                if (text)
                    values.push(text);
            }, this);

            if (values.length) {
                values = Ext4.unique(values);
            }
        }

        toSet['flags'] = values.length ? '<a onclick="SNPRC_EHR.Utils.showFlagPopup(\'' + LABKEY.Utils.encodeHtml(this.subjectId) + '\', this);">' + values.join('<br>') + '</div>' : null;
    },

    getExtendedItems: function () {
        return [{
            xtype: 'container',
            name: 'additionalInformation',
            style: 'padding-bottom: 10px;',
            border: false,
            defaults: {
                border: false
            },
            items: [{
                xtype: 'container',
                html: '<b>Additional Information</b><hr>'
            }, {
                layout: 'column',
                defaults: {
                    labelWidth: this.defaultLabelWidth
                },
                items: [{
                    xtype: 'container',
                    columnWidth: 0.5,
                    border: false,
                    defaults: {
                        labelWidth: this.defaultLabelWidth,
                        border: false,
                        style: 'margin-right: 20px;'
                    },
                    items: [{
                        xtype: 'displayfield',
                        width: 350,
                        fieldLabel: 'MHC Summary',
                        name: 'mhcSummary'
                    }, {
                        xtype: 'displayfield',
                        fieldLabel: 'Birth',
                        name: 'birth'
                    }, {
                        xtype: 'displayfield',
                        fieldLabel: 'Death',
                        name: 'death'
                    }]
                }, {
                    xtype: 'container',
                    columnWidth: 0.5,
                    defaults: {
                        labelWidth: this.defaultLabelWidth
                    },
                    items: [{
                        xtype: 'displayfield',
                        fieldLabel: 'Parent Information',
                        name: 'parents'
                    }
                        /*,{
                        xtype: 'displayfield',
                        fieldLabel: 'Pairing Type',
                        name: 'pairingType'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Cagemates',
                        name: 'cagemates'
                    } */
                    ]
                }]
            }]
        }];
    },

    onLoad: function (ids, resultMap) {
        if (this.disableAnimalLoad) {
            return;
        }

        if (this.isDestroyed) {
            return;
        }

        var toSet = {};

        var id = ids[0];
        var results = resultMap[id];
        if (!results) {
            if (id) {
                toSet['animalId'] = id;
                toSet['calculated_status'] = '<span style="background-color:yellow">Unknown</span>';
            }

            return;
        }

        this.appendDemographicsResults(toSet, results, id);

        this.appendWeightResults(toSet, results.getRecentWeights());

        this.appendCurrentAccountsResults(toSet, results.getCurrentAccounts());

        this.appendIdHistoryResults(toSet, results.getIdHistories());

        //this.appendCurrentPedigreeResults(toSet, results.getCurrentPedigree());

        this.appendCurrentDietResults(toSet, results.getCurrentDiet());

        this.appendRoommateResults(toSet, results.getCagemates(), id);

        this.appendAssignments(toSet, results.getActiveAssignments());

        if (!this.redacted) {
            this.appendAssignmentsAndGroups(toSet, results);
            this.appendGroups(toSet, results.getActiveAnimalGroups());
        }

        this.appendTreatmentRecords(toSet, results.getActiveTreatments());
        this.appendCases(toSet, results.getActiveCases());
        //this.appendCaseSummary(toSet, results.getActiveCases());

        this.appendFlags(toSet, results.getActiveFlags());
        this.appendTBResults(toSet, results.getTBRecord());

        if (this.showExtendedInformation) {
            this.appendBirthResults(toSet, results.getBirthInfo(), results.getBirth());
            this.appendDeathResults(toSet, results.getDeathInfo());
            this.appendParentageResults(toSet, results.getParents());
            this.appendMhcSummary(toSet, results.getMhcSummary());
        }

        this.getForm().setValues(toSet);
        this.afterLoad();
    }

//    appendAssignments: function(toSet, results){
//        var ret = this.callOverridden();
//    }

});

// Ext4.override(EHR.panel.EnterDataPanel, {
//
//     getQueueSections: function () {
//         return [{
//             header: 'Reports',
//             renderer: function (item) {
//                 return item;
//             },
//             items: [{
//                 xtype: 'ldk-linkbutton',
//                 text: 'Service Request Summary',
//                 linkCls: 'labkey-text-link',
//                 href: LABKEY.ActionURL.buildURL('ldk', 'runNotification', null, {key: 'org.labkey.snprc_ehr.notification.RequestAdminNotification'})
//             }]
//         }]
//     }
// });