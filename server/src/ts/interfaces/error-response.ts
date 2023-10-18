import {Response} from "express";
import {ErrorType} from "../error-enum";

export interface ErrorResponse {
    response: Response;
    statusCode?: number;
    errorType: ErrorType;
}
