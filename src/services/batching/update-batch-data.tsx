import {QRCodeRequest} from "../../ts/interfaces/qr-code-request-interfaces.tsx";

export function updateBatchData(setBatchData: (value: (((previousState: QRCodeRequest[]) => QRCodeRequest[]) | QRCodeRequest[])) => void) {
    return (data: QRCodeRequest) => {
        if (!data.type) {
            console.error("Data does not have a 'type' property.");
            return;
        }
        setBatchData((previousBatch: QRCodeRequest[]) => [...previousBatch, data]);
    };
}
