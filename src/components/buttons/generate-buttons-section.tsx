import {styles} from "../../assets/styles.tsx";
import {QRCodeGeneratorState} from "../../ts/interfaces/qr-code-generator-state.tsx";

interface GenerateButtonsSectionProperties {
    state: QRCodeGeneratorState;
    addToBatch: () => void;
    generateQRCode: () => void;
    qrBatchCount: number;
}
export const GenerateButtonsSection = ({state, addToBatch, generateQRCode, qrBatchCount}: GenerateButtonsSectionProperties) => {
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
