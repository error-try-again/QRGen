import {ProcessedQRData, QRData} from "../ts/interfaces/helper-interfaces";
import {AllRequests} from "../ts/types/all-request-types";
import {generateQR} from "../services/qr-code-services";
import {DEFAULT_QR_SIZE} from "../config";
import {validateData} from "../validators/data-validation-helper";
import {handleDataTypeSwitching} from "../utils/handle-data-type-switching";
import {Response} from "express";

export const processSingleQRCode = async (response: Response, qrData: QRData<AllRequests>, batch: boolean = false): Promise<ProcessedQRData<AllRequests>> => {
    validateData(response, qrData, batch);
    const { type, size = DEFAULT_QR_SIZE, precision = 'M', customData } = qrData;
    const updatedData = handleDataTypeSwitching(type, customData);
    const qrCodeData = await generateQR(updatedData, size, precision);
    return { ...qrData, qrCodeData };
};

export const generateQRCodesForBatch = async (response: Response, qrCodes: QRData<AllRequests>[]): Promise<ProcessedQRData<AllRequests>[]> => {
    try {
        return Promise.all(qrCodes.map((element) => processSingleQRCode(response, element, true)));
    } catch {
        return [];
    }
};
