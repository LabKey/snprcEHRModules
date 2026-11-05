import { formatDateTime } from '../services/formatDate';

describe('formatDateTime', () => {
    test('formats as MM/dd/yyyy HH:mm in 24-hour time', () => {
        expect(formatDateTime(new Date(2026, 8, 28, 13, 5))).toBe('09/28/2026 13:05');
        expect(formatDateTime(new Date(2026, 0, 2, 7, 0))).toBe('01/02/2026 07:00');
    });

    test('accepts the date string LabKey returns', () => {
        expect(formatDateTime('2026/09/28 13:45:00')).toBe('09/28/2026 13:45');
    });

    test('returns an empty string for a missing date', () => {
        expect(formatDateTime('')).toBe('');
        expect(formatDateTime(undefined)).toBe('');
    });
});
