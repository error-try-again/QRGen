export const sanitizeInput = <T>(input: T): T => {
  if (typeof input === 'string') {
    return [...input]
      .filter(char => !/[^\d\s,./:@A-Za-z-]/.test(char))
      .join('') as unknown as T;
  }
  return input;
};
