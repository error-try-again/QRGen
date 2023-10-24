export const isTextWithinQRSizeLimit = (text: string | undefined): boolean => {
  if (!text) {
    return false; // text is required
  }

  // QR code max char limit can vary. Here I assume 3,000 characters.
  return text.length <= 3000;
};
