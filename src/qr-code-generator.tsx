import React from 'react';
import 'leaflet/dist/leaflet.css';

// Styles
import {styles} from './assets/styles';

// Hooks
import {useTheme} from "./hooks/use-theme";

// Contexts
import {ThemeProvider} from "./contexts/theme-context";
import {QRCodeGeneratorProperties} from "./ts/interfaces/util-interfaces.tsx";

// Helpers & Callbacks
import {HandleTabChange} from "./helpers/handle-tab-change";

// Render methods
import {RenderAllTabs} from "./renders/render-all-tabs";

// Components
import {GenerateButtonsSection} from "./components/buttons/generate-buttons-section.tsx";
import {ThemeToggle} from "./components/theme/theme-toggle.tsx";
import {TabNav} from "./components/tabs/tab-nav.tsx";
import {QRSection} from "./components/qr/qr-section.tsx";
import {ErrorBoundary} from "./wrappers/error-boundary";
import {Links} from "./components/links/links.tsx";
import {CoreProvider} from "./contexts/core-context.tsx";
import {useCore} from "./hooks/use-core.tsx";

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

    const handleTabChange = HandleTabChange(setError, setBatchData, setQrBatchCount, dispatch, setActiveTab);
    const TabSections = RenderAllTabs(state, dispatch, setError, selectedCrypto, setSelectedCrypto);

    return <div style={styles.themeContainer}>
        <div style={styles.tabContainer}>
           <ThemeToggle theme={theme} toggleTheme={toggleTheme}/>
            {TabNav(activeTab, handleTabChange, setActiveTab)}
            {TabSections[activeTab]?.()}
            {error && <div style={styles.errorContainer}>{error}</div>}
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
