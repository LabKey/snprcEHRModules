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
                return new Array();
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


    }

//    appendAssignments: function(toSet, results){
//        var ret = this.callOverridden();
//    }

});
