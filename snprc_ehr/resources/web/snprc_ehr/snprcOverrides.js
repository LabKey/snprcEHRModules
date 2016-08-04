/*
 * Copyright (c) 2015 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.namespace('SNPRC_EHR');

LDK.Utils.splitIds = function(subjects, unsorted)
        {
            subjects = Ext4.String.trim(subjects);

            // Expand "X..Y" into X, X+1, X+2, ..., Y
            if (subjects.match(/[0-9]+\.\.[0-9]+/))
            {
                var sections = subjects.split("..");
                if (sections.length == 2)
                {
                    var num1 = parseInt(sections[0]);
                    var num2 = parseInt(sections[1]);
                    var start = Math.min(num1, num2);
                    var end = Math.max(num1, num2);

                    var result = [];
                    for (var x = start; x <= end; x++)
                    {
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

            if(subjects)
            {
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
    appendParentageResults: function(toSet, results){

        if (results){
            var parentMap = {};
            Ext4.each(results, function(row){
                var parent = row.parent;
                var relationship = row.relationship;

                if (parent && relationship){
                    var text = relationship + ' - ' + parent;

                    if (!parentMap[text])
                        parentMap[text] = [];

                    var method = row.method;
                    if (method){
                        parentMap[text].push(method);
                    }
                }
            }, this);

            var values = [];
            Ext4.Array.forEach(Ext4.Object.getKeys(parentMap).sort(), function(text){
                parentMap[text] = Ext4.unique(parentMap[text]);
                var method = parentMap[text].join(', ');
                    values.push('<a href="' + LABKEY.ActionURL.buildURL('query', 'executeQuery', null, {schemaName: 'study', 'query.queryName': 'demographicsParentStatus', 'query.Id~eq': this.subjectId}) + '" target="_blank">' + text + (method ? ' (' + method + ')' : '') + '</a>');
            }, this);

            if (values.length)
                toSet['parents'] = values.join('<br>');
        }
        else {
            toSet['parents'] = 'No data';
        }


    },

    appendIdHistoryResults: function(toSet, results){
        var text = [];
        if (results){
            var rows = [];
            Ext4.each(results, function(row){
                var newRow = {
                    id_value: row['value'],
                    id_type: row['id_type/description']
                };
                rows.push(newRow);
            }, this);

            Ext4.each(rows, function(r){
                text.push('<tr><td nowrap>' + r.id_type + ':' + '</td><td style="padding-left: 5px;" nowrap>' + r.id_value + '</td></tr>');
            }, this);
        }

        toSet['idHistories'] = text.length ? '<table>' + text.join('') + '</table>' : null;
    },


    getBaseItems: function(){
        return [{
            xtype: 'container',
            border: false,
            defaults: {
                border: false
            },
            items: [{
                xtype: 'container',
                html: '<b>Summary:</b><hr>'
            },{
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
                    },{
                        xtype: 'displayfield',
                        hidden: this.redacted,
                        name: 'assignments',
                        fieldLabel: 'Projects'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Groups',
                        hidden: this.redacted,
                        name: 'groups'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Open Problems',
                        name: 'openProblems'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Active Cases',
                        name: 'activeCases'
                    }]
                },{
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
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Gender',
                        name: 'gender'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Species',
                        name: 'species'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Age',
                        name: 'age'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Source',
                        name: 'source'
                    }]
                },{
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
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Last TB Date',
                        name: 'lastTB'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Weights',
                        name: 'weights'
                    },{
                        xtype: 'displayfield',
                        fieldLabel: 'Id History',
                        name: 'idHistories'
                    }]
                }]
            }]
        }];
    },
    onLoad: function(ids, resultMap){
        if (this.disableAnimalLoad){
            return;
        }

        if (this.isDestroyed){
            return;
        }

        var toSet = {};

        var id = ids[0];
        var results = resultMap[id];
        if (!results){
            if (id){
                toSet['animalId'] = id;
                toSet['calculated_status'] = '<span style="background-color:yellow">Unknown</span>';
            }

            return;
        }

        this.appendDemographicsResults(toSet, results, id);

        this.appendWeightResults(toSet, results.getRecentWeights());

        this.appendIdHistoryResults(toSet, results.getIdHistories());

        this.appendRoommateResults(toSet, results.getCagemates(), id);

        this.appendProblemList(toSet, results.getActiveProblems());
        this.appendAssignments(toSet, results.getActiveAssignments());

        if (!this.redacted){
            this.appendAssignmentsAndGroups(toSet, results);
            this.appendGroups(toSet, results.getActiveAnimalGroups());
        }

        this.appendSourceResults(toSet, results.getSourceRecord());
        this.appendTreatmentRecords(toSet, results.getActiveTreatments());
        this.appendCases(toSet, results.getActiveCases());
        this.appendCaseSummary(toSet, results.getActiveCases());

        this.appendFlags(toSet, results.getActiveFlags());
        this.appendTBResults(toSet, results.getTBRecord());

        if (this.showExtendedInformation){
            this.appendBirthResults(toSet, results.getBirthInfo(), results.getBirth());
            this.appendDeathResults(toSet, results.getDeathInfo());
            this.appendParentageResults(toSet, results.getParents());
        }

        this.getForm().setValues(toSet);
        this.afterLoad();
    }

//    appendAssignments: function(toSet, results){
//        var ret = this.callOverridden();
//    }

});
