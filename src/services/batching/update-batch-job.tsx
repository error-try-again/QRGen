import {QRCodeGeneratorState} from "../../ts/interfaces/qr-code-generator-state.tsx";
import {Tabs} from "../../ts/enums/tabs-enum.tsx";
import {QRCodeRequest} from "../../ts/interfaces/qr-code-request-interfaces.tsx";

export function updateBatchJob(state: QRCodeGeneratorState, activeTab: Tabs, addDataToBatch: (data: QRCodeRequest) => void, setQrBatchCount: (value: (((previousState: number) => number) | number)) => void) {
    return () => {
        const dataWithCorrectType = {customData: {...state}, type: Tabs[activeTab]};
        addDataToBatch(dataWithCorrectType);
        setQrBatchCount((previous: number) => previous + 1);
    };
}
