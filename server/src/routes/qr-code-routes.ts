import express from "express";
import {generateQRCodesForBatch, processSingleQRCode} from "../controllers/qr-code-controller";
import {validateBatchData} from "../validators/helpers/batch-validation-helper";
import {ProcessedQRData} from "../ts/interfaces/helper-interfaces";
import {AllRequests} from "../ts/types/all-request-types";
import {prepareAndSendArchive} from "./helpers/archival-helpers";

const router = express.Router();

router.post('/generate', async (request, response) => {
    if (!request.body || !request.body.type) {
        return response.status(400).json({message: "Invalid request data."});
    }
    try {
        const processedQRCode = await processSingleQRCode(request.body);
        return response.json({qrCodeURL: processedQRCode.qrCodeData});
    } catch (error) {
        console.error(error);
        return response.status(500).json({message: "Internal server error on QR code generation."});
    }
});

router.post('/batch', async (request: express.Request, response: express.Response) => {
    try {
        const {qrCodes} = request.body;
        if (!validateBatchData(qrCodes, response)) {
            return;
        }
        const qrCodesWithSanitizedData: ProcessedQRData<AllRequests>[] = await generateQRCodesForBatch(qrCodes);
        if (qrCodesWithSanitizedData) {
            await prepareAndSendArchive(qrCodesWithSanitizedData, response);
        } else {
            response.status(500).json({message: 'Internal server error on batch generation.'});
        }
    } catch {
        response.status(500).json({message: 'Internal server error on batch generation.'});
    }
});

// Friendly welcome message
router.get('/', (_request, response) => {
    if (response.headersSent) {
        return;
    }
    response.send('Welcome to the QR code generator API.');
});

export {router as qrCodeRoutes};
