import React, { useReducer, useState } from 'react';
import 'leaflet/dist/leaflet.css';

// Styles
import { styles } from './assets/styles';

// Hooks
import { useTheme } from "./hooks/use-theme";

// Contexts
import { ThemeProvider } from "./contexts/theme-context";

// Enums
import { Tabs } from "./ts/enums/tabs-enum";

// Interfaces
import { QRCodeRequest } from "./ts/interfaces/qr-code-request-interfaces.tsx";
import { QRCodeGeneratorProperties } from "./ts/interfaces/util-interfaces.tsx";

// Constants & Reducers
import { initialState } from "./constants/constants";
import { qrCodeReducer } from "./reducers/qr-code-reducer";

// Helpers & Callbacks
import {handleCryptoSelect} from "./helpers/handle-crypto-select";
import {HandleInputChange} from "./callbacks/handle-input-change";
import {HandleTabChange} from "./helpers/handle-tab-change";
import {HandleFetchError} from "./helpers/handle-fetch-error";

// Render methods
import {renderMeCard} from "./renders/render-me-card";
import {renderVCard} from "./renders/render-v-card";
import {renderAllTabs} from "./renders/render-all-tabs";
import {RenderFieldsAsColumns} from "./renders/render-fields-as-cols";
import {RenderInputFields} from "./renders/render-input-fields";
import {RenderContainerStyles} from "./renders/render-container-styles";

// Services
import {updateBatchData} from "./services/batching/update-batch-data";
import {updateBatchJob} from "./services/batching/update-batch-job";
import {QRGeneration} from "./services/qr-generation";
import {MapLocationPicker} from "./services/map-location-picker";

// Validators & Responses
import {ValidateInput} from "./validators/validate-input";
import {HandleErrorResponse} from "./responses/handle-error-response";
import {HandleBatchResponse} from "./responses/handle-batch-response";
import {HandleSingleResponse} from "./responses/handle-single-response";

// Components
import {GenerateButtonsSection} from "./components/generate-buttons-section";
import {ThemeToggle} from "./components/theme-toggle";
import {TabNav} from "./components/tab-nav.tsx";
import {QRSection} from "./components/qr-section";
import {ErrorBoundary} from "./wrappers/error-boundary";

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

    const handleErrorResponse = HandleErrorResponse(setError, setBatchData, setQrBatchCount, dispatch);
    const handleBatchResponse = HandleBatchResponse(setError, setBatchData, setQrBatchCount, dispatch);
    const handleSingleResponse = HandleSingleResponse(dispatch, setError, setBatchData, setQrBatchCount);
    const handleFetchError = HandleFetchError(setError, dispatch, setBatchData, setQrBatchCount);
    const validateInput = ValidateInput(activeTab, state, setError, setBatchData, setQrBatchCount, dispatch);
    const generateQRCode = QRGeneration(validateInput, dispatch, qrBatchCount, batchData, state, activeTab, handleErrorResponse, setError, setBatchData, setQrBatchCount, handleBatchResponse, handleSingleResponse, handleFetchError);

    const handleInputChange = HandleInputChange(state, dispatch);

    const renderInputFieldsInColumns = RenderFieldsAsColumns(state, handleInputChange, setError);
    const renderVCardFields = renderVCard(state, handleInputChange, renderInputFieldsInColumns);
    const renderMeCardFields = renderMeCard(renderInputFieldsInColumns);

    const LocationPicker = MapLocationPicker(dispatch, state);
    const handleCryptoChange = handleCryptoSelect(setSelectedCrypto, dispatch);
    const handleTabChange = HandleTabChange(setError, setBatchData, setQrBatchCount, dispatch, setTab);
    const renderInputFields = RenderInputFields(state, handleInputChange, setError);
    const TabSections = renderAllTabs(renderInputFields, state, handleInputChange, setError, LocationPicker, selectedCrypto, handleCryptoChange, renderVCardFields, renderMeCardFields);

    return <div style={containerStyles}>
        <div style={styles.tabContainer}>
            {ThemeToggle(toggleTheme, theme)}
            {TabNav(activeTab, handleTabChange, setTab)}
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
