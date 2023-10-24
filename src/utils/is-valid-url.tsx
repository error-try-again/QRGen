export const isValidUrl = (url: string | undefined): boolean => {
  try {
    if (!url) {
      return false; // url is required
    }
    return Boolean(new URL(url));
  } catch {
    return false;
  }
};
