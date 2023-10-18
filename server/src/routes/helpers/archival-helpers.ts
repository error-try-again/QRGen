import {ProcessedQRData} from "../../ts/interfaces/helper-interfaces";
import {AllRequests} from "../../ts/types/all-request-types";
import express from "express";
import archiver, {Archiver} from "archiver";
import {handleErrorStatus} from "./handle-error-status";
import {ErrorType} from "../../ts/error-enum";

export async function prepareAndSendArchive(qrCodesWithSanitizedData: ProcessedQRData<AllRequests>[], response: express.Response) {
    try {
        const archive = archiver('zip') as Archiver;

        // Set headers first to avoid "Cannot set headers after they are sent to the client" error
        setArchiveHeaders(response);

        // Handle archive events
        archive.on('error', (error) => {
            throw new Error(error.message);
        });

        // Pipe archive data to the response
        archive.pipe(response);

        // Append QR codes to archive
        await appendQRCodesToArchive(qrCodesWithSanitizedData, archive);

        // Finalize the archive
        await archive.finalize();
    } catch (error) {
        if (error instanceof Error) {
            handleErrorStatus({response, errorType: ErrorType.ARCHIVE_ERROR});
        }
    }
}

function setArchiveHeaders(response: express.Response) {
    try {
        // Provide a unique name for the archive corresponding to the date
        const dateStamp = new Date().toISOString().slice(0, 10);
        response.setHeader('Content-Type', 'application/zip');
        response.setHeader('Content-Disposition', `attachment; filename=qrBatch_${dateStamp}.zip`);
        return response;
    } catch {
        return handleErrorStatus({response, errorType: ErrorType.TROUBLE_SETTING_HEADERS})
    }
}

async function appendQRCodesToArchive(qrCodesWithSanitizedData: ProcessedQRData<AllRequests>[], archive: archiver.Archiver) {
    try {
        // Append QR codes to archive with a unique name for each file
        for (const [index, qrCode] of qrCodesWithSanitizedData.entries()) {
            const buffer = Buffer.from(qrCode.qrCodeData.split(',')[1], 'base64');
            const fileName = `${qrCode.type}_${index}.png`;
            archive.append(buffer, {name: fileName});
        }
    } catch {
        throw new Error(ErrorType.TROUBLE_APPENDING_FILES);
    }
}
