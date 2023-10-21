import { ValidEmail } from "../ts/interfaces/field-interfaces";

export const isValidEmail = ({ email }: ValidEmail) => {
  const regex = /^[\w.-]+@[\d.A-Za-z-]+\.[A-Za-z]{2,4}$/;
  return regex.test(email);
};
