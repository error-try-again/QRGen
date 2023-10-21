import { QRCodeErrorCorrectionLevel } from 'qrcode';

interface BaseQRData {
  type: string;
  size: number;
  precision?: QRCodeErrorCorrectionLevel;
}

export interface QRData<
  T = {
    [key: string]: string | number | boolean | undefined;
  }
> extends BaseQRData {
  customData: T;
}

export interface ProcessedQRData<T> extends QRData<T> {
  qrCodeData: string;
}
