import { generateQR } from './generate-qr.tsx';
import { handleDataTypeSwitching } from '../utils/handle-data-type-switching.tsx';
import { ErrorType } from '../ts/enums/error-enum.tsx';
import {
  ProcessedQRData,
  SingleQRDataParameters
} from "../ts/interfaces/util-interfaces.tsx";
import {AllRequests} from "../ts/types/request-types.tsx";
export const processSingleQRCode = async ({
                                     qrData: {
                                       type,
                                       customData,
                                       size,
                                       precision
                                     }
                                   }: SingleQRDataParameters): Promise<ProcessedQRData<AllRequests>> => {

  let updatedData;
  let updatedSize = size;
  let updatedPrecision = precision;

  try {
    updatedData = handleDataTypeSwitching(type, customData);
  } catch {
    throw new Error(ErrorType.INVALID_TYPE);
  }

  if (!size) {
    updatedSize = 200;
  }

  if (!precision) {
    updatedPrecision = 'M';
  }

  // Ensures that all three values are defined before generating the QR code
  if (updatedPrecision && updatedSize && updatedData) {
    const qrCodeData = await generateQR({
      data: updatedData,
      size: updatedSize,
      precision: updatedPrecision
    });
    return {type, customData, size, precision, qrCodeData};
  } else {
    throw new Error(ErrorType.MISSING_CUSTOM_DATA);
  }
};
