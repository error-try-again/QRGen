export const isValidEmail = (email: string): boolean => {
  const emailRegex = /^[\w.-]+@[\d.A-Za-z-]+\.[A-Za-z]{2,4}$/;
  return emailRegex.test(email);
};
