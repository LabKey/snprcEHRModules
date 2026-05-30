/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
// Print report using SSRS
const getSSRSUrl = () => {
    const url = LABKEY.getModuleProperty('snprc_ehr', 'SSRSServerURL')
    const ssrsFolder = LABKEY.getModuleProperty('snprc_ehr', 'SSRSReportFolder')
    return `${url}/${ssrsFolder}`
}

export const getReportPath = reportName => {
    const basePath = getSSRSUrl()
    return `${basePath}/${reportName}`
}
