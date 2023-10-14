import React, {useReducer, useState} from 'react';
import 'leaflet/dist/leaflet.css';
import {styles} from './assets/styles.tsx';
import {useTheme} from "./hooks/use-theme.tsx";
import {ThemeProvider} from "./contexts/theme-context.tsx";
import {Tabs} from "./ts/enums/tabs-enum.tsx";
import {QRCodeRequest} from "./ts/interfaces/qr-code-request-types.tsx";
import {QRCodeGeneratorProperties} from "./ts/interfaces/util-types.tsx";
import {ErrorBoundary} from "./wrappers/error-boundary.tsx";
import {initialState} from "./constants/constants.tsx";
import {qrCodeReducer} from "./reducers/qr-code-reducer.tsx";
import {HandleInputChange} from "./callbacks/handle-input-change.tsx";
import {handleCryptoSelect} from "./helpers/handle-crypto-select.tsx";
import {renderMeCard} from "./renders/render-me-card.tsx";
import {renderVCard} from "./renders/render-v-card.tsx";
import {MapLocationPicker} from "./services/map-location-picker.tsx";
import {ValidateInput} from "./validators/validate-input.tsx";
import {renderAllTabs} from "./renders/render-all-tabs.tsx";
import {RenderFieldsAsColumns} from "./renders/render-fields-as-cols.tsx";
import {RenderInputFields} from "./renders/render-input-fields.tsx";
import {updateBatchData} from "./services/batching/update-batch-data.tsx";
import {updateBatchJob} from "./services/batching/update-batch-job.tsx";
import {QRGeneration} from "./services/qr-generation.tsx";
import {RenderContainerStyles} from "./renders/render-container-styles.tsx";
import {HandleTabChange} from "./helpers/handle-tab-change.tsx";
import {HandleErrorResponse} from "./responses/handle-error-response.tsx";
import {HandleBatchResponse} from "./responses/handle-batch-response.tsx";
import {HandleSingleResponse} from "./responses/handle-single-response.tsx";
import {HandleFetchError} from "./helpers/handle-fetch-error.tsx";
import {GenerateButtonsSection} from "./components/generate-buttons-section.tsx";
import {ThemeToggle} from "./components/theme-toggle.tsx";
import {TabSection} from "./components/tab-section.tsx";
import {QRSection} from "./components/qr-section.tsx";

const QrCodeGenerator: React.FC<QRCodeGeneratorProperties> = () => {
    const [state, dispatch] = useReducer(qrCodeReducer, initialState);
    const [activeTab, setTab] = useState<Tabs>(Tabs.Text);
    const [selectedCrypto, setSelectedCrypto] = useState<string>('Bitcoin');
    const [error, setError] = useState<string>("");
    const [qrBatchCount, setQrBatchCount] = useState<number>(0); // Add state to keep track of batch count
    const [batchData, setBatchData] = useState<QRCodeRequest[]>([]);

    const {theme, toggleTheme} = useTheme();

    const containerStyles = RenderContainerStyles(theme);
    const updateBatch = updateBatchData(setBatchData);
    const addToBatch = updateBatchJob(state, activeTab, updateBatch, setQrBatchCount);
    const handleCryptoChange = handleCryptoSelect(setSelectedCrypto, dispatch);
    const handleInputChange = HandleInputChange(state, dispatch);
    const handleTabChange = HandleTabChange(setError, setBatchData, setQrBatchCount, dispatch, setTab);
    const handleErrorResponse = HandleErrorResponse(setError, setBatchData, setQrBatchCount, dispatch);
    const handleBatchResponse = HandleBatchResponse(setError, setBatchData, setQrBatchCount, dispatch);
    const handleSingleResponse = HandleSingleResponse(dispatch, setError, setBatchData, setQrBatchCount);
    const handleFetchError = HandleFetchError(setError, dispatch, setBatchData, setQrBatchCount);
    const LocationPicker = MapLocationPicker(dispatch, state);
    const validateInput = ValidateInput(activeTab, state, setError, setBatchData, setQrBatchCount, dispatch);
    const generateQRCode = QRGeneration(validateInput, dispatch, qrBatchCount, batchData, state, activeTab, handleErrorResponse, setError, setBatchData, setQrBatchCount, handleBatchResponse, handleSingleResponse, handleFetchError);
    const renderInputFields = RenderInputFields(state, handleInputChange, setError);
    const renderInputFieldsInColumns = RenderFieldsAsColumns(state, handleInputChange, setError);
    const renderVCardFields = renderVCard(state, handleInputChange, renderInputFieldsInColumns);
    const renderMeCardFields = renderMeCard(renderInputFieldsInColumns);
    const TabSections = renderAllTabs(renderInputFields, state, handleInputChange, setError, LocationPicker, selectedCrypto, handleCryptoChange, renderVCardFields, renderMeCardFields);

    return <div style={containerStyles}>
        <div style={styles.tabContainer}>
            {ThemeToggle(toggleTheme, theme)}
            {TabSection(activeTab, handleTabChange, setTab)}
            {TabSections[activeTab]?.()}
            {error && <div style={styles.errorContainer}>{error}</div>}
            {GenerateButtonsSection(addToBatch, state, generateQRCode, qrBatchCount)}
            {QRSection(state)}
        </div>
    </div>;
};

const WrappedQRCodeGenerator = () => (
    <ThemeProvider>
        <ErrorBoundary>
            <QrCodeGenerator/>
        </ErrorBoundary>
    </ThemeProvider>
);

export {WrappedQRCodeGenerator as QRCodeGenerator};
