import {QRCodeRequest} from "./qr-code-request-types.tsx";

export interface QRCodeGeneratorState extends QRCodeRequest {
    isLoading: boolean;
    qrCodeURL: string | null;
}
