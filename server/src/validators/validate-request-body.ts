import {Request, Response} from "express";
import {handleErrorStatus} from "../routes/helpers/handle-error-status";
import {ErrorType} from "../ts/enums/error-enum";
import {validateBatchQRData, validateQRData} from "./data-validation-helper";

export function errorHandlingMapping(error: Error, response: Response): void {
    const errorMappings: Record<string, number> = {
        [ErrorType.MISSING_REQUEST_TYPE]: 400,
        [ErrorType.INVALID_TYPE]: 400,
        [ErrorType.MISSING_DATA_BODY]: 400,
        [ErrorType.MISSING_CUSTOM_DATA]: 400,
        [ErrorType.BATCH_MISSING_DATA_BODY]: 400,
        [ErrorType.BATCH_MISSING_CUSTOM_DATA]: 400,
        [ErrorType.DUPLICATE_QR_CODES]: 409,
        [ErrorType.EXCEEDS_MAX_LIMIT]: 413,
        [ErrorType.ERROR_SETTING_HEADERS]: 500,
        [ErrorType.ERROR_APPENDING_FILES]: 500,
        [ErrorType.ERROR_FINALIZING_ARCHIVE]: 500,
        [ErrorType.UNKNOWN_ARCHIVE_ERROR]: 500
    };

    const statusCode = errorMappings[error.message] || 500;

    // Ensure error.message is a valid ErrorType or use the generic fallback error.
    const errorType = error.message in ErrorType ? error.message as ErrorType : ErrorType.GENERIC_ERROR;

    handleErrorStatus({ errorType, response, statusCode });
}

export const validateRequest = (request: Request, _response: Response, next: () => void): void => {
    if (typeof request.body !== 'object' || request.body === null) {
        throw new Error(ErrorType.INVALID_TYPE);
    }

    const {type} = request.body;
    if (type) {
        validateQRData(request.body);
        next();
    } else {
        throw new Error(ErrorType.MISSING_REQUEST_TYPE);
    }
};

export const validateBatchRequest = (request: Request, _response: Response, next: () => void): void => {
    if (Array.isArray(request.body.qrCodes)) {
        validateBatchQRData({qrData: request.body.qrCodes});
        next();
    } else {
        throw new TypeError(ErrorType.MISSING_REQUEST_TYPE);
    }
};
