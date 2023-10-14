import QRCode from "qrcode";
import {DEFAULT_QR_SIZE} from "../config";

export const generateQR = async (data: string, size: string | number): Promise<string> => {
    let parsedSize = Number(size);
    if (Number.isNaN(parsedSize) || parsedSize < 50 || parsedSize > 1000) {
        console.log(`Invalid size: ${size}. Using default size: ${DEFAULT_QR_SIZE}`);
        parsedSize = DEFAULT_QR_SIZE;
    }

    return QRCode.toDataURL(data, {
        errorCorrectionLevel: 'H',
        margin: 1,
        width: parsedSize,
        type: 'image/png'
    });
};
