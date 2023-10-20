import {Tabs} from "../../ts/enums/tabs-enum";
import {QRCodeRequest} from "../../ts/interfaces/qr-code-request-interfaces";
import {UpdateBatchJobProperties} from "../../ts/interfaces/component-interfaces.tsx";

export function UpdateBatchJob({state, activeTab, setQrBatchCount, setBatchData}: UpdateBatchJobProperties) {
    return () => {
        const dataToBatch = {customData: {...state}, type: Tabs[activeTab]};
        setBatchData((previousBatch: QRCodeRequest[]) => [...previousBatch, dataToBatch]);
        setQrBatchCount((previous: number) => previous + 1);
    };
}
