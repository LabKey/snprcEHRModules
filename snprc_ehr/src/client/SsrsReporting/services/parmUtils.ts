import moment from 'moment';
declare var LABKEY: any;

export interface ReportParm {
    name: string;
    type: string;
    label: string;
    value: string;
};


export const parseParms = (parms: string): ReportParm[] => {
    // parm format is: name, type, label, value
    // Each parm gets its own object
    // Example: 'TargetID:string:Target ID:31415, ...' = [{name: 'TargetId', type: 'string', label: 'Target ID', value: '31415' }, ...]
    let reportParms: ReportParm[] = [];

    const now = moment().format("YYYY-MM-DD hh:mm:ss");
    
    if (parms.length > 0) {
        let parmArray = parms.split(',')
        parmArray.map((parm) => {
            let keyValues: string[];
            keyValues = parm.split(':');

            reportParms.push({ 
                    name: keyValues[0].trim(), 
                    type: keyValues[1].trim().toLowerCase(), 
                    label: keyValues[2].trim(), 
                    ...(keyValues.length === 4 && { value: keyValues[3].trim() } ), //value is present
                    ...(keyValues.length === 3 && (keyValues[1].toLowerCase().includes('date') ? {value: now} : { value: ''})) //add value
                });
        })
    }
    return reportParms;
}

export const parmsToQueryString =  (parmArray: ReportParm[]): string => {
    // used to create the URL query string
    let parms = ''
    parmArray.map( (parm): void => {
        parms += (`&${parm.name}=${parm.value}`)
    })
    
    return encodeURI(parms);
}
