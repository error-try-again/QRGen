import {QRCodeRequest} from "./qr-code-request-interfaces.tsx";

export interface QRCodeGeneratorState extends QRCodeRequest {
    isLoading: boolean;
    qrCodeURL: string | null;
}
