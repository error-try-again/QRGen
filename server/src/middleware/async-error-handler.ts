import { Request, Response } from "express";
import { errorHandlingMapping } from "../validators/validate-request-body";

export const asyncErrorHandler = (
  handler: (request: Request, response: Response) => Promise<void>,
) => {
  return async (request: Request, response: Response): Promise<void> => {
    try {
      await handler(request, response);
    } catch (error) {
      if (error instanceof Error) {
        errorHandlingMapping(error, response);
      }
    }
  };
};
