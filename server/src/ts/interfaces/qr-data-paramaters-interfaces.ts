import { QRData } from './helper-interfaces';
import { AllRequests } from '../types/all-request-types';
import { QRCodeErrorCorrectionLevel } from 'qrcode';

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

export interface GenerateQRParameters {
  data: string;
  size: string | number;
  precision: QRCodeErrorCorrectionLevel;
}
