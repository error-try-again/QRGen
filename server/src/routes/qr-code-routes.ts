import express, { Request, Response, Router } from 'express';
import {
  generateQRCodesForBatch,
  processSingleQRCode
} from '../controllers/qr-code-controller';
import { prepareAndSendArchive } from './helpers/archival-helpers';
import {
  validateBatchRequest,
  validateRequest
} from '../validators/validate-request-body';
import { asyncErrorHandler } from '../middleware/async-error-handler';

const router: Router = express.Router();

router.post(
  '/generate',
  asyncErrorHandler(async (request: Request, response: Response) => {
    validateRequest(request, async () => {
      const { body } = request;
      const processedQRCode = await processSingleQRCode({ qrData: body });
      response.json({ qrCodeURL: processedQRCode.qrCodeData });
    });
  })
);

router.post(
  '/batch',
  asyncErrorHandler(async (request: Request, response: Response) => {
    validateBatchRequest(request, async () => {
      const { body } = request;
      const { qrCodes } = body;
      const qrData = await generateQRCodesForBatch({ qrData: qrCodes });
      if (qrData.length > 0) {
        await prepareAndSendArchive(qrData, response);
      }
    });
  })
);

export { router as qrCodeRoutes };
