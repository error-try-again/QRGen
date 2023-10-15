import QRCode, {QRCodeErrorCorrectionLevel} from "qrcode";
import {DEFAULT_QR_SIZE} from "../config";

export const generateQR = async (data: string, size: string | number, precision: QRCodeErrorCorrectionLevel): Promise<string> => {
    let parsedSize = Number(size);

    if (Number.isNaN(parsedSize) || parsedSize < 50 || parsedSize > 1000) {
        console.log(`Invalid size: ${size}. Using default size: ${DEFAULT_QR_SIZE}`);
        parsedSize = DEFAULT_QR_SIZE;
    }

    return QRCode.toDataURL(data, {
        errorCorrectionLevel: precision,
        margin: 1,
        type: 'image/png',
        width: parsedSize
    });
};
