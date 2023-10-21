import { QRCodeRequest } from '../interfaces/qr-code-request-interfaces';

export type QRCodeGeneratorAction =
  | { field: keyof QRCodeRequest; type: 'SET_FIELD'; value: string }
  | { type: 'SET_ERROR'; value: string }
  | { type: 'SET_BATCH_DATA'; value: QRCodeRequest[] }
  | { type: 'SET_QR_BATCH_COUNT'; value: number }
  | { type: 'SET_ACTIVE_TAB'; value: string }
  | { type: 'SET_SELECTED_CRYPTO'; value: string }
  | { type: 'SET_SELECTED_VERSION'; value: string }
  | { type: 'SET_IS_VALID'; value: boolean }
  | { type: 'SET_IS_VALIDATING'; value: boolean }
  | { type: 'SET_LOADING'; value: boolean }
  | { type: 'SET_QRCODE_URL'; value: string | null }
  | { type: 'RESET_STATE' };
