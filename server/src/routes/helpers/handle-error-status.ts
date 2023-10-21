import { ErrorResponse } from '../../ts/interfaces/error-response';

export const handleErrorStatus = ({
  response,
  statusCode = 500,
  errorType,
  message
}: ErrorResponse & { message?: string }) => {
  response.status(statusCode).json(errorType ? { errorType } : { message });
};
