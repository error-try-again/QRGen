import { QRData } from "./helper-interfaces";
import { AllRequests } from "../types/all-request-types";

export interface SingleQRDataParameters {
  qrData: QRData<AllRequests>;
}
export interface BatchQRDataParameters {
  qrData: QRData<AllRequests>[];
}

export interface QRGenericData<T extends AllRequests> {
  qrData: QRData<T>;
}

export interface QRGenericDataArray<T extends AllRequests> {
  qrData: QRData<T>[];
}
