import { ErrorType } from '../enums/error-enum';
import { Response } from 'express';

export interface ResponseInterfaces {
  errorType: ErrorType;
  message?: string;
  response: Response;
  statusCode?: number;
}
