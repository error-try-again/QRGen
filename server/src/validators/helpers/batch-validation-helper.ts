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
        return response.status(400).json({message: 'Invalid batch data. Duplicate entries detected.'});
    }

    if (qrCodes.length > MAX_QR_CODES) {
        return response.status(400).json({message: `Invalid batch data. Maximum number of entries is ${MAX_QR_CODES}.`});
    }

    for (const qrCode of qrCodes) {
        try {
            validateData(qrCode, qrCode.type);
        } catch (error) {
            console.log(error);
            return response.status(400).json({message: `Invalid data for type: ${qrCode.type}`});
        }
    }

    return response.status(200).json({message: 'Batch data validated.'});
};
