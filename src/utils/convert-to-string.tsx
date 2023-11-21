import { DefaultUnknownParameters } from '../ts/interfaces/util-interfaces';

// Convert value to string to ensure type safety and prevent errors
export function convertValueToString({
  value
}: DefaultUnknownParameters): string {
  if (typeof value === 'string') {
    return value;
  }
  if (typeof value === 'boolean') {
    // convert boolean to string for display
    return value ? 'True' : 'False';
  }
  if (value === null || value === undefined) {
    // convert null or undefined to empty string
    return '';
  }
  return String(value);
}
