import {styles} from "../../assets/styles.tsx";
import {QRCodeGeneratorState} from "../../ts/interfaces/qr-code-generator-state.tsx";
import {UpdateBatchJob} from "../../services/batching/update-batch-job.tsx";
import {Tabs} from "../../ts/enums/tabs-enum.tsx";
import React from "react";
import {QRCodeRequest} from "../../ts/interfaces/qr-code-request-interfaces.tsx";
import {QRGeneration} from "../../services/qr-generation.tsx";
import {QRCodeGeneratorAction} from "../../ts/types/reducer-types.tsx";

interface GenerateButtonsSectionProperties {
    state: QRCodeGeneratorState;
    dispatch: React.Dispatch<QRCodeGeneratorAction>,
    activeTab: Tabs;
    qrBatchCount: number;
    setQrBatchCount: React.Dispatch<React.SetStateAction<number>>;
    batchData: QRCodeRequest[];
    setBatchData: React.Dispatch<React.SetStateAction<QRCodeRequest[]>>;
    setError: (value: (((previousState: string) => string) | string)) => void;
}

export const GenerateButtonsSection = ({
                                           state,
                                           dispatch,
                                           activeTab,
                                           qrBatchCount,
                                           setQrBatchCount,
                                           batchData,
                                           setBatchData,
                                           setError
                                       }: GenerateButtonsSectionProperties) => {

    const generateQRCode = QRGeneration({
        dispatch,
        qrBatchCount,
        batchData,
        state,
        activeTab,
        setError,
        setBatchData,
        setQrBatchCount
    });

    const addToBatch = UpdateBatchJob(
        {state, activeTab, setQrBatchCount, setBatchData});

    const {generateButton, qrButtonsContainer} = styles;
    return <div style={qrButtonsContainer}>
        <button onClick={addToBatch}
                style={generateButton}
                aria-label="Add To Bulk"
                aria-busy={state.isLoading}>
            Add To Bulk
        </button>
        <button style={generateButton}
                onClick={generateQRCode}
                aria-label="Generate QR Code"
                aria-busy={state.isLoading}>
            {qrBatchCount >= 1 ? `Generate Zip (${qrBatchCount})` : 'Generate QR Code'}
        </button>
    </div>;
};
