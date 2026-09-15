const pad = (n: number) => String(n).padStart(2, '0');

export const formatDateTime = (value: string | Date): string => {
    if (!value) return '';
    const d = new Date(value);
    return `${pad(d.getMonth() + 1)}/${pad(d.getDate())}/${d.getFullYear()} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
}