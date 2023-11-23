import { ReactNode } from 'react';
import {QRCodeErrorCorrectionLevel} from "qrcode";
import {AllRequests} from "../types/request-types.tsx";

export interface QRCodeGeneratorProperties {
  children?: ReactNode;
}

export interface ErrorBoundaryProperties {
  children: ReactNode;
}

export interface DefaultUnknownParameters {
  value: unknown;
}

export interface SingleQRDataParameters {
  qrData: QRData<AllRequests>;
}

export interface GenerateQRParameters {
  data: string;
  size: string | number;
  precision: QRCodeErrorCorrectionLevel;
}

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
