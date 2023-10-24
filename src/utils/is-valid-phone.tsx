export const isValidPhoneNumber = (phone: string | undefined): boolean => {
  if (!phone) {
    return false; // phone is required
  }
  const regex = /^\+*\(?\d{1,4}\)?[\d\s./-]*$/;
  return regex.test(phone);
};
