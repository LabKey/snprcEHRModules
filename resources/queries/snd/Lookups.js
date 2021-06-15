

var console = require("console");
var LABKEY = require("labkey");

function init(event){

    if (event === 'truncate') {
        throw "Not allowed to truncate snd.Lookups. Truncating this table can orphan lookup values in snd data.";
    }
}

function onUpsert(row, errors) {

    if (row.LookupSetId === undefined || row.LookupSetId == 'undefined') {
        LABKEY.Query.selectRows({
            schemaName: 'snd',
            queryName: 'LookupSets',
            columns: 'LookupSetId',
            scope: this,
            filterArray: [
                LABKEY.Filter.create('SetName', row.SetName, LABKEY.Filter.Types.EQUAL),

            ],
            success: function (data) {
                if (data.rows && data.rows.length) {
                    row.LookupSetId = data.rows[0].LookupSetId;

                    //  console.log('caching ' + cacheKey + ': ' + row.GroupId);
                }
            },
            failure: function (error) {
                console.log('Select rows error');
                console.log(error);
            }
        });
    }
}

function beforeInsert(row, errors) {
    onUpsert(row, errors);
}

function beforeUpdate(row, errors) {
    onUpsert(row, errors);
}


