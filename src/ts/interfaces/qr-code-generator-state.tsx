import { QRCodeRequest } from './qr-code-request-interfaces';

export interface QRCodeGeneratorState extends QRCodeRequest {
  isLoading: boolean;
  qrCodeURL: string | null;
}
