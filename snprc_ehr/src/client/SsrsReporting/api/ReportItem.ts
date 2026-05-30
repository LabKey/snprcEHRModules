/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
export interface ReportItem {
    id: number;
    sortOrder?: number | null;
    label: string;
    value: string;
    description: string;
    parameters?: string;
    rsParameters?:string;
}