import { AllRequests, RequestTypeMap } from '../ts/types/all-request-types';
import { formatters } from '../formatters/format-mapping';

export const handleDataTypeSwitching = <T extends AllRequests>(
  type: string,
  data: T
): string => {
  if (!Object.keys(formatters).includes(type)) {
    throw new Error('Invalid type provided.');
  }

  // TODO: Need to find a better means of sanitizing input
  // return formatters[type as keyof RequestTypeMap](sanitizeInput(data));

  return formatters[type as keyof RequestTypeMap](data);
};
