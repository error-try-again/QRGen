import { resetBatchAndLoadingState } from "../../helpers/reset-loading-state.tsx";
import { HandleResponseParameters } from "../../ts/interfaces/component-interfaces.tsx";
import { processSingleQRCode } from "../qr-code-controller.tsx";
import { saveAs } from "file-saver";
import JSZip from 'jszip';

export function HandleBatchResponse({
                                        setError,
                                        setBatchData,
                                        setQrBatchCount,
                                        dispatch
                                    }: HandleResponseParameters) {
    return async (data: any) => {
        if (!data || !data.qrCodes || !Array.isArray(data.qrCodes)) {
            setError('Invalid data');
            return;
        }

        const zip = new JSZip();
        const folder = zip.folder("QR Codes");

        try {
            for (const qrData of data.qrCodes) {
                const qrCodeData = await processSingleQRCode({ qrData });
                const response = await fetch(qrCodeData.qrCodeData);
                const blob = await response.blob();
                if (folder) {
                    folder.file(`${qrData.type}-${Date.now()}.png`, blob, { binary: true });
                } else {
                    setError('Error processing QR codes');
                    return;
                }
            }

            const zipBlob = await zip.generateAsync({ type: "blob" });
            saveAs(zipBlob, "QRCodes.zip");
        } catch (error) {
            console.error('Error processing QR codes:', error);
            setError('Error processing QR codes');
        } finally {
            resetBatchAndLoadingState({ setBatchData, setQrBatchCount, dispatch });
            setError('');
        }
    };
}
