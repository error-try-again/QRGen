import express, {Request, Response, Router} from "express";
import {generateQRCodesForBatch, processSingleQRCode} from "../controllers/qr-code-controller";
import {ProcessedQRData} from "../ts/interfaces/helper-interfaces";
import {AllRequests} from "../ts/types/all-request-types";
import {prepareAndSendArchive} from "./helpers/archival-helpers";
import {validateRequestBody} from "../validators/validate-request-body";
import {handleErrorStatus} from "./helpers/handle-error-status";
import {ErrorType} from "../ts/error-enum";

const router: Router = express.Router();

// Route to generate a single QR code
router.post('/generate', async (request: Request, response: Response) => {
    validateRequestBody(request, response, async () => {
        try {
            const processedQRCode = await processSingleQRCode(response, request.body);
            response.json({ qrCodeURL: processedQRCode.qrCodeData });
        } catch {
            handleErrorStatus({response, statusCode: 500, errorType: ErrorType.SOMETHING_WENT_WRONG});
        }
    });
});

// Route to generate QR codes in batch
router.post('/batch', async (request: Request, response: Response) => {
    validateRequestBody(request, response, async () => {
        try {
            const qrCodesWithSanitizedData: ProcessedQRData<AllRequests>[] = await generateQRCodesForBatch(response, request.body);
            if (qrCodesWithSanitizedData) {
                await prepareAndSendArchive(qrCodesWithSanitizedData, response);
            } else {
                handleErrorStatus({response, statusCode: 500, errorType: ErrorType.COULD_NOT_GENERATE_ARCHIVE});
            }
        } catch {
            handleErrorStatus({response, statusCode: 500, errorType: ErrorType.SOMETHING_WENT_WRONG});
        }
    });
});

// Route for the welcome message
router.get('/', (_request: Request, response: Response) => {
    if (!response.headersSent) {
        response.send('Welcome to the QR code generator API.');
    }
});

export { router as qrCodeRoutes };
