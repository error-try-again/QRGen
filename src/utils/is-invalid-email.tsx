import { areValidCcBcc } from './are-valid-cc-bcc.tsx';

export const isInvalidEmail = (email: string): boolean => {
  return !areValidCcBcc({ email });
};
