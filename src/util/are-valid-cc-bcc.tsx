import {isValidEmail} from "./is-email-valid.tsx";

export const areValidCcBcc = ((emails: string) => {
    // Split the emails by commas
    const emailArray = emails.split(',').map(email => email.trim());

    // Check if each email is valid
    return emailArray.every((element) => isValidEmail(element));
});
