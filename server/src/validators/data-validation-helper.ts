import {AllRequests, RequestTypeMap} from "../ts/types/all-request-types";
import {QRData} from "../ts/interfaces/helper-interfaces";
import {validators} from "./validation-mapping";
import {MAX_QR_CODES} from "../config";
import {Response} from "express";
import {ErrorType} from "../ts/error-enum";
import {handleErrorStatus} from "../routes/helpers/handle-error-status";

export const validateData = <T extends AllRequests>(response: Response, data: QRData<T>, batch: boolean = false): boolean => {
    if (!data) {
        handleErrorStatus({response, errorType: ErrorType.MISSING_DATA});
        return false;
    }
    if (batch) {
        if (Array.isArray(data)) {
            return validateBatch(response, data);
        }

        handleErrorStatus({response, errorType: ErrorType.INVALID_BATCH});
        return false;
    }
    return hasCustomData(response, data) && isValidType(response, data);
};

const hasCustomData = <T extends AllRequests>(response: Response, data: QRData<T>): boolean => {
    if (data.customData) {
        return true;
    }
    handleErrorStatus({response, errorType: ErrorType.MISSING_CUSTOM_DATA});
    return false;
};

const isValidType = <T extends AllRequests>(response: Response, data: QRData<T>): boolean => {
    if (validators[data.type as keyof RequestTypeMap]) {
        return true;
    }
    handleErrorStatus({response, errorType: ErrorType.INVALID_TYPE});
    return false;
};

const validateBatch = <T extends AllRequests>(response: Response, data: QRData<T>[]): boolean => {
    if (!isArrayWithElements({response, data})) {
        return false;
    }
    if (!hasUniqueQRCodeElements({response, data})) {
        return false;
    }
    return isWithinMaxLimit({response, data});
};

const isArrayWithElements = <T extends AllRequests>({response, data}: { response: Response; data: QRData<T>[] }): boolean => {
    if (Array.isArray(data) && data.length > 0) {
        return true;
    }
    handleErrorStatus({response, errorType: ErrorType.INVALID_BATCH});
    return false;
};

const hasUniqueQRCodeElements = <T extends AllRequests>({response, data}: { response: Response; data: QRData<T>[] }): boolean => {
    if (new Set(data.map((element) => JSON.stringify(element))).size === data.length) {
        return true;
    }
    handleErrorStatus({response, errorType: ErrorType.DUPLICATE_QRCODES});
    return false;
};

const isWithinMaxLimit = <T extends AllRequests>({response, data}: { response: Response; data: QRData<T>[] }): boolean => {
    if (data.length <= MAX_QR_CODES) {
        return true;
    }
    handleErrorStatus({response, errorType: ErrorType.MAX_LIMIT_EXCEEDED});
    return false;
};
