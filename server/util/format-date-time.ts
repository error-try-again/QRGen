
export const formatDatetime = (date: string) => new Date(date).toISOString().replaceAll(/[:-]/g, '').split('.')[0];
