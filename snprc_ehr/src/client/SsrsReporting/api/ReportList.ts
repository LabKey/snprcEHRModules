import { OptionsType } from 'react-select'

export interface ReportType {
    id: number;
    label: string;
    value: string;
    description: string;
    parameters: string;

}
export const reportList: OptionsType<ReportType> =  
    [
        {id: 1, label: 'Long Term Clinic Admissions', value: 'ReportS/report/LabkeyReports/LongTermClinic', description: 'Clinical admissions over 21 days',  parameters:'' },
        {id: 2, label: 'Overdue TB and Physical', value: 'ReportS/report/CenterReports/Routine%20Health/OverduePhyTB', description: 'Last TB test and physical exams that are over 180 days',  parameters:'' },
        {id: 3, label: 'Baboon weaning', value: 'ReportS/report/ColonyReports/Boon_weaning', description: 'Baboon infants that are ready to be weaned',  parameters:'' },
        {id: 4, label: 'Rhesus SPF weaning', value: 'ReportS/report/ColonyReports/rh2_weaning', description: 'Rhesus infants that are ready to be weaned', parameters:'' },
        {id: 5, label: 'Colony Census (current)', value: 'testReport1', description: 'Colony census as of today', parameters:'' },
        {id: 6, label: 'Colony Census (select date)', value: 'testReport2', description: 'Colony census on a specific date',  parameters:'targetDate:Date:Target Date' },
        {id: 7, label: 'Birth record report', value: 'ReportS/report/Development/BirthRecord', description: 'Birth certificate for animal',  parameters:'TargetID:string:Animal Id' },
        {id: 8, label: 'IACUC 3yr Rollover (Standard)', value: 'ReportS/report/CenterReports/IACUC/3YrRollover', description: 'Target Date is used to determine 3yr period NULL uses today.', parameters:'IACUC:string:IACUC, TargetDate:Date:Target Date, Mode:String:Mode:Standard' },
        {id: 8, label: 'IACUC 3yr Rollover (Backdate)', value: 'ReportS/report/CenterReports/IACUC/3YrRollover' ,description: 'Target Date sets the 3yr end date.  Start date is 3 years before target date.', parameters:'IACUC:string:IACUC, TargetDate:Date:Target Date, Mode:String:Mode:BackDate' },
        {id: 10, label: 'IACUC 3yr Rollover (Harddate)', value: 'ReportS/report/CenterReports/IACUC/3YrRollover', description: 'Target date sets the end date.  Start date is the date file start date before the target date. Could result in more or less than 3 yrs', parameters:'IACUC:string:IACUC, TargetDate:Date:Target Date, Mode:String:Mode:HardDate' }
    ];
    