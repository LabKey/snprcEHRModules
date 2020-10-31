import { OptionsType } from 'react-select'
import { ReportItem } from '../ReportItem'

// API test data
//Report server docs: https://docs.microsoft.com/en-us/sql/reporting-services/url-access-parameter-reference?view=sql-server-ver15
export const fetchReportList = () => {  
    return new Promise<OptionsType<ReportItem>> ( (resolve, reject) => {
        resolve(
            [
                {id: 1, label: 'Long Term Clinic Admissions', value: 'LabkeyReports/LongTermClinic', description: 'Clinical admissions over 21 days',  parameters:'', rsParameters:'&rs:Command=Render' },
                {id: 2, label: 'Overdue TB and Physical', value: 'CenterReports/Routine%20Health/OverduePhyTB', description: 'Last TB test and physical exams that are over 180 days',  parameters:'', rsParameters: '&rs:Command=Render' },
                {id: 3, label: 'Baboon weaning', value: 'ColonyReports/Boon_weaning', description: 'Baboon infants that are ready to be weaned',  parameters:'', rsParameters: '&rs:Command=Render' },
                {id: 4, label: 'Rhesus SPF weaning', value: 'ColonyReports/rh2_weaning', description: 'Rhesus infants that are ready to be weaned', parameters:'', rsParameters: '&rs:Command=Render' },
                {id: 5, label: 'Colony Census (current)', value: 'testReport1', description: 'Colony census as of today', parameters:'', rsParameters: '&rs:Command=Render' },
                {id: 6, label: 'Colony Census (select date)', value: 'testReport2', description: 'Colony census on a specific date',  parameters:'targetDate:Date:Target Date', rsParameters: '&rs:Command=Render' },
                {id: 7, label: 'Birth record report', value: 'Development/BirthRecord', description: 'Birth certificate for animal',  parameters:'TargetID:string:Animal Id', rsParameters: '&rc:Parameters=Collapsed' },
                {id: 8, label: 'IACUC 3yr Rollover (Standard)', value: 'CenterReports/IACUC/3YrRollover&Mode=1', description: 'Target Date is used to determine 3yr period.', parameters:'IACUC:string:IACUC, TargetDate:Date:Target Date', rsParameters: '&rc:Parameters=Collapsed' },
                {id: 8, label: 'IACUC 3yr Rollover (Backdate)', value: 'CenterReports/IACUC/3YrRollover&Mode=2' ,description: 'Target Date sets the end date.  Start date is 3 years before target date.', parameters:'IACUC:string:IACUC, TargetDate:Date:Target Date', rsParameters: '&rc:Parameters=Collapsed' },
                {id: 10, label: 'IACUC 3yr Rollover (Harddate)', value: 'CenterReports/IACUC/3YrRollover&Mode=3', description: 'Target date sets the end date.  Start date is the start date before the target date. Could result in more or less than 3 yrs.', parameters:'IACUC:string:IACUC, TargetDate:Date:Target Date', rsParameters: '&rc:Parameters=Collapsed' }
            ]
        ), (error: string ) => {
            reject(error)
        }
    
    })
}
    