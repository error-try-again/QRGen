import { isValidEmail } from './is-email-valid';
import { AreValidCcBccParameters } from '../ts/interfaces/field-interfaces';

export const areValidCcBcc = ({ emails }: AreValidCcBccParameters) => {
  // Split the emails by commas
  const emailArray = emails.split(',').map(email => email.trim());

  // Check if each email is valid
  return emailArray.every(element => isValidEmail({ email: element }));
};
