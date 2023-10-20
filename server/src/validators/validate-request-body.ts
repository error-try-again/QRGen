import {Request, Response} from "express";
import {handleErrorStatus} from "../routes/helpers/handle-error-status";
import {ErrorType} from "../ts/enums/error-enum";
import {validateBatchQRData, validateQRData} from "./data-validation-helper";

export const validateRequest = (request: Request, response: Response, next: () => void): void => {
    try {
        const {body} = request;
        const {type} = body;
        if (type) {
            validateQRData(body);
            next();
        } else {
            handleErrorStatus({errorType: ErrorType.MISSING_REQUEST_TYPE, response, statusCode: 400});
        }
    } catch (error) {
        if (error instanceof Error) {
            handleErrorStatus({errorType: error.message as ErrorType, response});
        }
    }
};

export const validateBatchRequest = (request: Request, response: Response, next: () => void): void => {
    try {
        const {body} = request;
        const {qrCodes} = body;
        if (Array.isArray(qrCodes)) {
            validateBatchQRData({qrData: qrCodes});
            next();
        } else {
            handleErrorStatus({errorType: ErrorType.MISSING_REQUEST_TYPE, response, statusCode: 400});
        }
    } catch (error) {
        if (error instanceof Error) {
            handleErrorStatus({errorType: error.message as ErrorType, response});
        }
    }
};
