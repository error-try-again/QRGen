import {ProcessedQRData} from "../../ts/interfaces/helper-interfaces";
import {AllRequests} from "../../ts/types/all-request-types";
import express from "express";
import archiver, {Archiver} from "archiver";
import {handleArchiveError} from "../../middleware/error-handlers";

export async function prepareAndSendArchive(qrCodesWithSanitizedData: ProcessedQRData<AllRequests>[], response: express.Response) {
    try {
        const archive = archiver('zip') as Archiver;
        archive.on('error', (error) => {
            throw new Error(error.message);
        });
        setArchiveHeaders(response);
        await appendQRCodesToArchive(qrCodesWithSanitizedData, archive);
        await archive.finalize();
    } catch (error) {
        if (error instanceof Error && error.message.includes('Trouble setting headers.')) {
            handleArchiveError(error, response);
        }
    }
}

function setArchiveHeaders(response: express.Response) {
    const dateStamp = new Date().toISOString().slice(0, 10);
    response.setHeader('Content-Type', 'application/zip');
    response.setHeader('Content-Disposition', `attachment; filename=qrBatch_${dateStamp}.zip`);
    return response;
}

async function appendQRCodesToArchive(qrCodesWithSanitizedData: ProcessedQRData<AllRequests>[], archive: archiver.Archiver) {
    try {
        for (const [index, qrCode] of qrCodesWithSanitizedData.entries()) {
            const buffer = Buffer.from(qrCode.qrCodeData.split(',')[1], 'base64');
            const fileName = `${qrCode.type}_${index}.png`;
            archive.append(buffer, {name: fileName});
        }
    } catch {
        throw new Error('Trouble appending files to archive.');
    }
}
