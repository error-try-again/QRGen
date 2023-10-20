import express, {Request, Response, Router} from "express";
import {generateQRCodesForBatch, processSingleQRCode} from "../controllers/qr-code-controller";
import {prepareAndSendArchive} from "./helpers/archival-helpers";
import {validateBatchRequest, validateRequest} from "../validators/validate-request-body";
import {handleErrorStatus} from "./helpers/handle-error-status";
import {ErrorType} from "../ts/enums/error-enum";

const router: Router = express.Router();

// Route to generate a single QR code
router.post('/generate', async (request: Request, response: Response) => {
    validateRequest(request, response, async () => {
        try {
            const {body} = request;
            const [processedQRCode] = await Promise.all([processSingleQRCode({qrData: body})]);
            response.json({ qrCodeURL: processedQRCode.qrCodeData });
        } catch {
            handleErrorStatus({response, statusCode: 500, errorType: ErrorType.GENERIC_ERROR});
        }
    });
});

// Route to generate QR codes in batch
router.post('/batch', async (request: Request, response: Response) => {
    validateBatchRequest(request, response, async () => {
        try {
            let numb = 0;
            const {body} = request;
            const {qrCodes} = body;
            const [qrData] = await Promise.all([generateQRCodesForBatch({qrData: qrCodes})]);

            if (qrData.length > 0) {
                numb++;
                console.log("NUMBER!!: " + numb);


                await prepareAndSendArchive(qrData, response);
            } else {
                handleErrorStatus({response, statusCode: 500, errorType: ErrorType.QR_CODE_GENERATION_ERROR});
            }
        } catch {
            handleErrorStatus({response, statusCode: 500, errorType: ErrorType.GENERIC_ERROR});
        }
    });
});

// Route for the welcome message
router.get('/', (_request: Request, response: Response) => {
        response.send('Welcome to the QR code generator API.');
});

export { router as qrCodeRoutes };
