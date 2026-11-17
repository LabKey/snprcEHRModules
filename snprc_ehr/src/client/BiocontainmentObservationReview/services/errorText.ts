// LabKey API failures set exception; JavaScript and network errors set message
export const errorText = (error: any, fallback = 'Unexpected error'): string =>
    error?.exception ?? error?.message ?? fallback;
