import { ProcessedQRData } from '../../ts/interfaces/helper-interfaces';
import { AllRequests } from '../../ts/types/all-request-types';
import { Response } from 'express';
import archiver, { Archiver } from 'archiver';
import { handleErrorStatus } from './handle-error-status';
import { ErrorType } from '../../ts/enums/error-enum';

async function setArchiveHeaders(response: Response) {
  try {
    // Provide a unique name for the archive corresponding to the date and time
    const dateStamp = new Date()
      .toISOString()
      .slice(0, 19)
      .replaceAll(':', '-');
    response.setHeader('Content-Type', 'application/zip');
    response.setHeader(
      'Content-Disposition',
      `attachment; filename=bulk_qr_${dateStamp}.zip`
    );
  } catch {
    handleErrorStatus({ response, errorType: ErrorType.ERROR_SETTING_HEADERS });
    throw new TypeError(ErrorType.ERROR_SETTING_HEADERS);
  }
}

export async function prepareAndSendArchive(
  qrCodes: ProcessedQRData<AllRequests>[],
  response: Response
) {
  try {
    const archive = archiver('zip') as Archiver;

    await setArchiveHeaders(response);

    archive.pipe(response);

    appendQRCodesToArchive({ response, qrCodes, archive });

    await archive.finalize();
  } catch (error) {
    if (error instanceof Error) {
      handleErrorStatus({
        response,
        errorType: ErrorType.ERROR_FINALIZING_ARCHIVE
      });
      throw new TypeError(ErrorType.ERROR_FINALIZING_ARCHIVE);
    } else {
      handleErrorStatus({
        response,
        errorType: ErrorType.UNKNOWN_ARCHIVE_ERROR
      });
      throw new TypeError(ErrorType.UNKNOWN_ARCHIVE_ERROR);
    }
  }
}

function appendQRCodesToArchive({
  response,
  qrCodes,
  archive
}: {
  archive: Archiver;
  qrCodes: ProcessedQRData<AllRequests>[];
  response: Response;
}) {
  // Append QR codes to archive with a unique name for each file
  for (const [index, qrCode] of qrCodes.entries()) {
    let buffer = Buffer.from('');
    let fileName = '';

    try {
      // Ensure qrCode.qrCodeData is a string and starts with the expected format
      if (qrCode.qrCodeData.startsWith('data:image/png;base64,')) {
        buffer = Buffer.from(qrCode.qrCodeData.split(',')[1], 'base64');
        fileName = `${qrCode.type}_${index}.png`;
      }
    } catch {
      throw new Error(
        `QR code at index ${index} is not in the expected format.`
      );
    }

    try {
      if (buffer.length > 0 && fileName.length > 0) {
        archive.append(buffer, { name: fileName });
      }
    } catch {
      handleErrorStatus({
        response,
        errorType: ErrorType.ERROR_APPENDING_FILES
      });
      throw new TypeError(ErrorType.ERROR_APPENDING_FILES);
    }
  }
}
