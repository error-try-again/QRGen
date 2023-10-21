import QRCode, { QRCodeErrorCorrectionLevel } from 'qrcode';
import { DEFAULT_QR_SIZE } from '../config';

interface GenerateQRParameters {
  data: string;
  size: string | number;
  precision: QRCodeErrorCorrectionLevel;
}

export const generateQR = async ({
  data,
  size,
  precision
}: GenerateQRParameters): Promise<string> => {
  let parsedSize = Number(size);

  if (Number.isNaN(parsedSize) || parsedSize < 50 || parsedSize > 1000) {
    parsedSize = DEFAULT_QR_SIZE;
  }

  return QRCode.toDataURL(data, {
    errorCorrectionLevel: precision,
    margin: 1,
    type: 'image/png',
    width: parsedSize
  });
};
