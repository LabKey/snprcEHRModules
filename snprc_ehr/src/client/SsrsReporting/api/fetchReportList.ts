import { ReportItem } from './ReportItem'
import { request } from '../../Shared/api/api'

const parse = rows => {
    return rows.map( ( { data } ) => {
        const reportItem: ReportItem = 
         { 
            id: data.Id.value, 
            sortOrder: data.SortOrder.value,
            label: data.Label.value,
            value: data.Report.value,
            description: data.Description.value,
            parameters: data.Parameters.value,
            rsParameters: data.rsParameters.value
        }
        return reportItem;
    })
}

export const fetchReportList = (): Promise<ReportItem[]> => {
    return new Promise((resolve, reject) => {
        request({
            schemaName: 'snprc_ehr',
            queryName: 'ExternalReports',
            columns: ['Id', 'SortOrder', 'Label', 'Report', 'Description', 'Parameters', 'rsParameters'],
            sort: 'SortOrder'
        }).then(({ rows }) => {
            const parsedRows:ReportItem[] = parse(rows)
            resolve(parsedRows)
        }).catch(error => {
            console.log('error', error)
            reject(error)
        })
    })
}

    