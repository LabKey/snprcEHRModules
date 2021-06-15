

function init(event){

    if (event === 'truncate') {
        throw "Not allowed to truncate snd.LookupSets. Truncating this table can orphan lookup values in snd data.";
    }
}