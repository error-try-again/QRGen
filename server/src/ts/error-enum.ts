import {MAX_QR_CODES} from "../config";

export enum ErrorType {
    MISSING_DATA = 'Check request body for missing data.',
    INVALID_BATCH = 'Batch request must be an array of QR codes.',
    MISSING_CUSTOM_DATA = 'QR code missing custom data.',
    INVALID_TYPE = 'Invalid QR code type.',
    DUPLICATE_QR_CODES = 'Batch request must contain unique QR codes.',
    MAX_LIMIT_EXCEEDED = `Batch request must contain no more than ${MAX_QR_CODES} QR codes.`,
    ARCHIVE_ERROR = 'There was an issue preparing your archive.',
    SOMETHING_WENT_WRONG = 'Something went wrong on our end. Please try again later.',
    TROUBLE_SETTING_HEADERS = 'Trouble setting headers.',
    TROUBLE_APPENDING_FILES = 'Trouble appending files to archive.',
    MISSING_REQUEST_BODY = 'Invalid request on Message Body; check request body for missing data.',
    MISSING_REQUEST_TYPE = 'Invalid Type on Message Body; check request Type for missing data.',
    COULD_NOT_GENERATE_ARCHIVE = 'Could not generate archive/zip.',
}
