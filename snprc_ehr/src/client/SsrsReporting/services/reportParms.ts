
export interface ReportParm {
    name: string;
    type: string;
    value: string;
    label: string;
};


export const parseParms = (parms: string): Array<ReportParm> => {

    // Each key/value pair gets its own object
    // Example: 'TargetID:string:label, startDate:Date:label, endDate:Date:label'
    let reportParms: ReportParm[] = [];

    if (parms.length > 0) {
        let parmArray: string[] = parms.split(',')
        parmArray.map((parm) => {
            let keyValues: string[];
            keyValues = parm.split(':');

            reportParms.push({ 
                    name: keyValues[0].trim(), 
                    type: keyValues[1].trim(), 
                    label: keyValues[2].trim(), 
                    ...(keyValues.length === 4 && { value: keyValues[3].trim() === '' ? '' : keyValues[3].trim()} )
                });
        })
    }

    console.log('reportParams', reportParms)
    return reportParms;
}