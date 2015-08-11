/*
 * Copyright (c) 2013-2015 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.namespace('WNPRC_EHR');

EHR.Utils.splitIds = function(subjects)
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
                result.sort();
                return result;
            }
            else
                return new Array();
        };
