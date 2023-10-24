import { areValidCcBcc } from './are-valid-cc-bcc';

export const isInvalidEmail = (email: string): boolean => {
  return !areValidCcBcc({ email });
};
