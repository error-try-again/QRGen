import React from 'react';
import 'leaflet/dist/leaflet.css';
import {styles} from './assets/styles';
import {useTheme} from "./hooks/use-theme";
import {ThemeProvider} from "./contexts/theme-context";
import {QRCodeGeneratorProperties} from "./ts/interfaces/util-interfaces";
import {HandleTabChange} from "./helpers/handle-tab-change";
import {RenderAllTabs} from "./renders/render-all-tabs";
import {GenerateButtonsSection} from "./components/buttons/generate-buttons-section";
import {ThemeToggle} from "./components/theme/theme-toggle";
import {TabNav} from "./components/tabs/tab-nav";
import {QRSection} from "./components/qr/qr-section";
import {ErrorBoundary} from "./wrappers/error-boundary";
import {Links} from "./components/links/links";
import {CoreProvider} from "./contexts/core-context";
import {useCore} from "./hooks/use-core";

const QrCodeGenerator: React.FC<QRCodeGeneratorProperties> = () => {

    const {
        dispatch,
        state,
        batchData,
        setBatchData,
        qrBatchCount,
        setQrBatchCount,
        error,
        setError,
        selectedCrypto,
        setSelectedCrypto,
        activeTab,
        setActiveTab
    } = useCore();

    const {theme, toggleTheme} = useTheme();

    const handleTabChange = HandleTabChange({setError : setError, setBatchData : setBatchData, setQrBatchCount : setQrBatchCount, dispatch : dispatch, setTab : setActiveTab});
    const TabSections = RenderAllTabs({state : state, dispatch : dispatch, setError : setError, selectedCrypto : selectedCrypto, setSelectedCrypto : setSelectedCrypto});

    const {themeContainer, tabContainer, errorContainer} = styles;
    return <div style={themeContainer}>
        <div style={tabContainer}>
            {ThemeToggle({theme, toggleTheme})}
            {TabNav({activeTab : activeTab, handleTabChange : handleTabChange, setTab : setActiveTab})}
            {TabSections[activeTab]?.()}
            {error && <div style={errorContainer}>{error}</div>}
            <GenerateButtonsSection
                state={state}
                dispatch={dispatch}
                activeTab={activeTab}
                qrBatchCount={qrBatchCount}
                setQrBatchCount={setQrBatchCount}
                batchData={batchData}
                setBatchData={setBatchData}
                setError={setError}
            />
            {QRSection(state)}
        </div>
    </div>;
};

const WrappedQRCodeGenerator = () => (
    <ThemeProvider>
        <ErrorBoundary>
            <CoreProvider>
                <QrCodeGenerator/>
                <Links/>
            </CoreProvider>
        </ErrorBoundary>
    </ThemeProvider>
);

export {WrappedQRCodeGenerator as QRCodeGenerator};
