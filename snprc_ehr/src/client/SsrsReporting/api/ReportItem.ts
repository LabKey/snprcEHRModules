export interface ReportItem {
    id: number;
    sortOrder?: number | null;
    label: string;
    value: string;
    description: string;
    parameters?: string;
    rsParameters?:string;
}