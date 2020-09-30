declare var LABKEY: any;

// Print report using SSRS
const getSSRSUrl = () => {
    const url = LABKEY.getModuleProperty('snprc_ehr', 'SSRSServerURL')
    const ssrsFolder = LABKEY.getModuleProperty('snprc_ehr', 'SSRSReportFolder')
    return `${url}/${ssrsFolder}`
}

export const getReportPath = (reportName: string) => {
    const basePath = getSSRSUrl()
    return `${basePath}/${reportName}&rc:Parameters=Collapsed&`
}
