import { Response } from "express";
import { ErrorType } from "../enums/error-enum";

export interface ErrorResponse {
  errorType: ErrorType;
  message?: string;
  response: Response;
  statusCode?: number;
}
