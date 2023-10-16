import {styles} from "../../assets/styles.tsx";
import {QRCodeGeneratorState} from "../../ts/interfaces/qr-code-generator-state.tsx";
import {UpdateBatchJob} from "../../services/batching/update-batch-job.tsx";
import {Tabs} from "../../ts/enums/tabs-enum.tsx";
import React from "react";
import {QRCodeRequest} from "../../ts/interfaces/qr-code-request-interfaces.tsx";

interface GenerateButtonsSectionProperties {
    state: QRCodeGeneratorState;
    activeTab: Tabs;
    generateQRCode: () => void;
    qrBatchCount: number;
    setQrBatchCount: React.Dispatch<React.SetStateAction<number>>;
    setBatchData: React.Dispatch<React.SetStateAction<QRCodeRequest[]>>;
}

export const GenerateButtonsSection = ({
                                           state,
                                           activeTab,
                                           generateQRCode,
                                           qrBatchCount,
                                           setQrBatchCount,
                                           setBatchData
                                       }: GenerateButtonsSectionProperties) => {

    const addToBatch = UpdateBatchJob({state, activeTab, setQrBatchCount, setBatchData});

    return <div style={styles.qrButtonsContainer}>
        <button onClick={addToBatch}
                style={styles.generateButton}
                aria-label="Add To Bulk"
                aria-busy={state.isLoading}>
            Add To Bulk
        </button>
        <button style={styles.generateButton}
                onClick={generateQRCode}
                aria-label="Generate QR Code"
                aria-busy={state.isLoading}>
            {qrBatchCount >= 1 ? `Generate Zip (${qrBatchCount})` : 'Generate QR Code'}
        </button>
    </div>;
};
