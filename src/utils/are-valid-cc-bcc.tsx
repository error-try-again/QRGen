import { isValidEmail } from './is-email-valid.tsx';

export const areValidCcBcc = (emails: { email: string }): boolean =>
  emails.email
    .split(',')
    .map(email => email.trim())
    .every(element => isValidEmail(element));
