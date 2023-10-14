import {ProcessedQRData, QRData} from "../ts/interfaces/helper-interfaces";
import {AllRequests} from "../ts/types/all-request-types";
import {generateQR} from "../services/qr-code-services";
import {DEFAULT_QR_SIZE} from "../config";
import {validateData} from "../validators/helpers/data-validation-helper";
import {handleDataTypeSwitching} from "../utils/handle-data-type-switching";

export const processSingleQRCode = async <T extends AllRequests>(qrData: QRData<T>): Promise<ProcessedQRData<T>> => {
    validateData(qrData, qrData.type);

    const {type, size, customData} = qrData;
    const sanitizedData = handleDataTypeSwitching(type, customData);

    const qrCodeData = await generateQR(sanitizedData, size ?? DEFAULT_QR_SIZE);
    return {...qrData, qrCodeData};
};

export const generateQRCodesForBatch = async (qrCodes: QRData[]): Promise<ProcessedQRData<AllRequests>[]> => {
    return await Promise.all(qrCodes.map((element) => processSingleQRCode(element)));
};
