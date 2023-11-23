export const formatDatetime = (date: string) => {
  const isoDate = new Date(date).toISOString();
  return isoDate.split(/[:-]/g).join('').split('.')[0];
};
