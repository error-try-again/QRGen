export enum ErrorType {
  MISSING_DATA_BODY = 'Request body data is missing.',
  MISSING_CUSTOM_DATA = 'Custom data in the request body is missing.',
  MISSING_REQUEST_TYPE = 'Request type is missing.',
  INVALID_TYPE = 'Request type is invalid.',
  DUPLICATE_QR_CODES = 'Duplicate QR codes are not allowed.',
  EXCEEDS_MAX_LIMIT = 'Exceeds max limit of 1000 QR codes.',
  BATCH_MISSING_DATA_BODY = 'Request body data is missing for one or more QR codes.',
  BATCH_MISSING_CUSTOM_DATA = 'Custom data in the request body is missing for one or more QR codes.',
  ERROR_SETTING_HEADERS = 'Error occurred while setting headers.',
  ERROR_APPENDING_FILES = 'Error occurred while appending files to the archive.',
  ERROR_FINALIZING_ARCHIVE = 'Error occurred while finalizing the archive.',
  UNKNOWN_ARCHIVE_ERROR = 'Unknown error occurred while creating the archive.',
}
