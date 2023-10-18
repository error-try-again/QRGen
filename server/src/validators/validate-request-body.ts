import {Request, Response} from "express";
import {handleErrorStatus} from "../routes/helpers/handle-error-status";
import {ErrorType} from "../ts/error-enum";

export const validateRequestBody = (request: Request, response: Response, next: () => void): void => {
    // Smoke test for if the request body exists
    // If it does, check if it's an array or an object
    if (request) {
        if (Array.isArray(request.body.qrCodes)) {
            console.log('PASS 3:', request.body);
            next();
        } else if (request.body.type) {
            next();
        } else {
            handleErrorStatus({response, statusCode: 400, errorType: ErrorType.MISSING_REQUEST_TYPE});
        }
    } else {
        handleErrorStatus({response, statusCode: 400, errorType: ErrorType.MISSING_REQUEST_BODY});
    }
};
