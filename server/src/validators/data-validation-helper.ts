import {AllRequests, RequestTypeMap} from "../ts/types/all-request-types";
import {QRData} from "../ts/interfaces/helper-interfaces";
import {validators} from "./validation-mapping";
import {MAX_QR_CODES} from "../config";
import {ErrorType} from "../ts/enums/error-enum";
import {QRGenericData, QRGenericDataArray} from "../ts/interfaces/qr-data-paramaters";


// Validates the qrData for a batch of QR codes
export const validateBatchQRData = <T extends AllRequests>({qrData}: QRGenericDataArray<T>): void => {
    if (isNotArrayOrIsEmpty({qrData})) {
        throw new Error(ErrorType.BATCH_MISSING_DATA_BODY);
    }
    if (elementsMissingData({qrData})) {
        throw new Error(ErrorType.BATCH_MISSING_DATA_BODY);
    }
    if (hasDuplicateQRCodeElements({qrData})) {
        throw new Error(ErrorType.DUPLICATE_QR_CODES);
    }
    if (exceedsMaxLimits({qrData})) {
        throw new Error(ErrorType.EXCEEDS_MAX_LIMIT);
    }
    if (elementsMissingCustomData({qrData})) {
        throw new Error(ErrorType.BATCH_MISSING_CUSTOM_DATA);
    }
    if (hasInvalidElementType({qrData})) {
        throw new Error(ErrorType.INVALID_TYPE);
    }
};

// Validates the qrData for a single QR code
export const validateQRData = <T extends AllRequests>(qrData: QRData<T>): void => {
    if (isDataMissing({qrData: qrData})) {
        throw new Error(ErrorType.MISSING_DATA_BODY);
    }
    if (isCustomDataMissing({qrData: qrData})) {
        throw new Error(ErrorType.MISSING_CUSTOM_DATA);
    }
    if (isTypeInvalid({qrData: qrData})) {
        throw new Error(ErrorType.INVALID_TYPE);
    }
};


// Checks if the request qrData body is missing
const isDataMissing = <T extends AllRequests>({qrData}: QRGenericData<T>): boolean => {
    return !qrData;
};

// Checks if the custom qrData object is missing
const isCustomDataMissing = <T extends AllRequests>({qrData}: QRGenericData<T>): boolean => {
    return !qrData.customData;
};

// Checks if validator exists, if not, the type is invalid
const isValidatorMissing = <T extends AllRequests>({qrData}: QRGenericData<T>): boolean => {
    return !validators[qrData.type as keyof RequestTypeMap];
};

// Checks if the custom qrData is valid for the given type
const isTypeInvalid = <T extends AllRequests>({qrData}: QRGenericData<T>): boolean => {
    if (isValidatorMissing({qrData: qrData})) {
        return true;
    }
    const validator = validators[qrData.type as keyof RequestTypeMap];
    return !validator(qrData.customData);
};

// Checks if the qrData is not an array or is empty

const isNotArrayOrIsEmpty = <T extends AllRequests>({qrData}: QRGenericDataArray<T>): boolean => {
    return !Array.isArray(qrData) || qrData.length === 0;
};

// Checks if there are duplicate QR code elements using hash mapping
const hasDuplicateQRCodeElements = <T extends AllRequests>({qrData}: QRGenericDataArray<T>): boolean => {
    const hashMapping: {
        [key: string]: boolean
    } = {};
    for (const element of qrData) {
        const hash = JSON.stringify(element);
        if (hashMapping[hash]) {
            return true;
        }
        hashMapping[hash] = true;
    }
    return false;
};

// Checks if the number of QR codes exceeds the maximum limit
const exceedsMaxLimits = <T extends AllRequests>({qrData}: QRGenericDataArray<T>): boolean => {
    return qrData.length > MAX_QR_CODES;
};

// Checks if any of the elements are missing qrData
const elementsMissingData = <T extends AllRequests>({qrData}: QRGenericDataArray<T>): boolean => qrData.some((element) => {
    return isDataMissing({qrData: element});
});

// Checks if any of the elements are missing custom qrData
const elementsMissingCustomData = <T extends AllRequests>({qrData}: QRGenericDataArray<T>): boolean => qrData.some((element) => {
    return isCustomDataMissing({qrData: element});
});

// Checks if any of the elements have an invalid type
const hasInvalidElementType = <T extends AllRequests>({qrData}: QRGenericDataArray<T>): boolean => qrData.some((element) => {
    return isTypeInvalid({qrData: element});
});
