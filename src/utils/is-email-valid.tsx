export const isValidEmail = ((email: string) => {
    const regex = /^[\w.-]+@[\d.A-Za-z-]+\.[A-Za-z]{2,4}$/;
    return regex.test(email);
});
