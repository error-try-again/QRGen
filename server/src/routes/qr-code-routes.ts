import express, { Request, Response, Router } from 'express';
import {generateQRCodesForBatch, processSingleQRCode} from "../controllers/qr-code-controller";
import {prepareAndSendArchive} from "./helpers/archival-helpers";
import {errorHandlingMapping, validateBatchRequest, validateRequest} from "../validators/validate-request-body";

const router: Router = express.Router();

const asyncErrorHandler = (handler: (request: Request, response: Response) => Promise<void>) => {
    return async (request: Request, response: Response): Promise<void> => {
        try {
            await handler(request, response);
        } catch (error) {
            if (error instanceof Error) {
                errorHandlingMapping(error, response);
            }
        }
    };
};

router.post('/generate', asyncErrorHandler(async (request: Request, response: Response) => {
    validateRequest(request, response, async () => {
        const {body} = request;
        const processedQRCode = await processSingleQRCode({qrData: body});
        response.json({qrCodeURL: processedQRCode.qrCodeData});
    });
}));

router.post('/batch', asyncErrorHandler(async (request: Request, response: Response) => {
    validateBatchRequest(request, response, async () => {
        const {body} = request;
        const {qrCodes} = body;
        const qrData = await generateQRCodesForBatch({qrData: qrCodes});
        if (qrData.length > 0) {
            await prepareAndSendArchive(qrData, response);
        }
    });
}));

router.get('/', (_request: Request, response: Response) => {
    response.send('Welcome to the QR code generator API.');
});

export {router as qrCodeRoutes};
