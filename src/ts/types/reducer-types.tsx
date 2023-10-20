import {QRCodeRequest} from "../interfaces/qr-code-request-interfaces";

export type QRCodeGeneratorAction =
    | { type: 'SET_FIELD'; field: keyof QRCodeRequest; value: string }
    | { type: 'SET_LOADING'; value: boolean }
    | { type: 'SET_QRCODE_URL'; value: string | null }
    | { type: 'RESET_STATE' };
