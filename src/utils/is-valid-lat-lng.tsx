export const isValidLatLng = (
  latitude: string | undefined,
  longitude: string | undefined
): boolean => {
  if (!latitude || !longitude) {
    return false; // latitude and longitude are required
  }
  const latRegex = /^-?([1-8]?[1-9]|[1-9]0)\.\d{1,6}/;
  const lngRegex = /^-?((1?[1-7]?|[1-9]0?)[1-9]|[1-9]0)\.\d{1,6}/;
  return (
    latRegex.test(latitude.toString()) && lngRegex.test(longitude.toString())
  );
};
