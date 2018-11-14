/*
 * Copyright (c) 2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

 require("ehr/triggers").initScript(this);

 function onInit(event, helper){
     helper.setScriptOptions({
         allowFutureDates: true
     });
 }



function onUpsert(helper, scriptErrors, row, oldRow){

        if (row.LookupSetId === undefined || row.LookupSetId == 'undefined')
        {
            LABKEY.Query.selectRows({
                schemaName: 'snd',
                queryName: 'LookupSets',
                columns: 'LookupSetId',
                scope: this,
                filterArray: [
                    LABKEY.Filter.create('SetName', row.SetName, LABKEY.Filter.Types.EQUAL),
                    
                ],
                success: function (data)
                {
                    if (data.rows && data.rows.length)
                    {
                        row.LookupSetId = data.rows[0].LookupSetId;
                     
                      //  console.log('caching ' + cacheKey + ': ' + row.GroupId);
                    }
                },
                failure: function (error)
                {
                    console.log('Select rows error');
                    console.log(error);
                }
            });
        }

    }


