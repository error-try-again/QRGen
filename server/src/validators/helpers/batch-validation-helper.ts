import {QRData} from "../../ts/interfaces/helper-interfaces";
import {Response} from "express";
import {MAX_QR_CODES} from "../../config";
import {validateData} from "./data-validation-helper";

export const validateBatchData = (qrCodes: QRData[], response: Response) => {
    if (!Array.isArray(qrCodes) || qrCodes.length === 0) {
        return response.status(400).json({message: 'Invalid batch data. Must be a non-empty array.'});
    }

    const uniqueData = new Set(qrCodes.map((element) => JSON.stringify(element)));

    if (uniqueData.size !== qrCodes.length) {
        return false;
    }

    if (qrCodes.length > MAX_QR_CODES) {
        return false;
    }

    for (const qrCode of qrCodes) {
        try {
            validateData(qrCode, qrCode.type);
        } catch (error) {
            console.log(error);
            return false;
        }
    }

    return true;
};
