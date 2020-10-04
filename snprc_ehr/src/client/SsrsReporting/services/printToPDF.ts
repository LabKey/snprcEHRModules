declare var LABKEY: any;
import { ReportItem} from '../api/ReportItem'

// Print report using SSRS
const getSSRSUrl = () => {
    const url = LABKEY.getModuleProperty('snprc_ehr', 'SSRSServerURL')
    //const ssrsFolder = LABKEY.getModuleProperty('snprc_ehr', 'SSRSReportFolder')
    return `${url}`
}

//Report server docs: https://docs.microsoft.com/en-us/sql/reporting-services/url-access-parameter-reference?view=sql-server-ver15
export const printToPDF = (report: ReportItem, parms: string):void => {

    const basePath = getSSRSUrl()
    const fullPath = `${basePath}/${report.value}${parms}${report.rsParameters}`
    const left = window.screenX + 20;
    window.open(
        fullPath,
        "_blank",
        `location=yes,height=850,width=768,status=yes, left=${left}`
    );
    
    console.log ('fullpath', fullPath)
}