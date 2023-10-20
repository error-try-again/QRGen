
import {Tabs} from "../../ts/enums/tabs-enum";
import React from "react";
import {QRCodeRequest} from "../../ts/interfaces/qr-code-request-interfaces";
import {QRCodeGeneratorState} from "../../ts/interfaces/qr-code-generator-state";

interface UpdateBatchJobProperties {
    state: QRCodeGeneratorState;
    activeTab: Tabs;
    setQrBatchCount: React.Dispatch<React.SetStateAction<number>>;
    setBatchData: React.Dispatch<React.SetStateAction<QRCodeRequest[]>>;
}

export function UpdateBatchJob({state, activeTab, setQrBatchCount, setBatchData}: UpdateBatchJobProperties) {
    return () => {
        const dataToBatch = {customData: {...state}, type: Tabs[activeTab]};
        if (!dataToBatch.type) {
            console.error("Data does not have a 'type' property.");
            return;
        }
        setBatchData((previousBatch: QRCodeRequest[]) => [...previousBatch, dataToBatch]);
        setQrBatchCount((previous: number) => previous + 1);
    };
}
