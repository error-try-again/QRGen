import {ErrorResponse} from "../../ts/interfaces/error-response";

export const handleErrorStatus = ({response, statusCode, errorType}: ErrorResponse) => {
    if (statusCode) {
        response.status(statusCode).json({message: errorType});
    } else {
        response.status(500).json({message: errorType});
    }
};
