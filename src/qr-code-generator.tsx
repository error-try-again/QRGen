import React from 'react';
import 'leaflet/dist/leaflet.css';
import { styles } from './assets/styles';
import { ThemeProvider } from './contexts/theme-context';
import { QRCodeGeneratorProperties } from './ts/interfaces/util-interfaces';
import { HandleTabChange } from './helpers/handle-tab-change';
import { TabRenderer } from './renders/render-all-tabs';
import { GenerateButtonsSection } from './components/buttons/generate-buttons-section';
import { ThemeToggle } from './components/theme/theme-toggle';
import { TabNav } from './components/tabs/tab-nav';
import { QRSection } from './components/qr/qr-section';
import { ErrorBoundary } from './wrappers/error-boundary';
import { Links } from './components/links/links';
import { CoreProvider } from './contexts/core-context';
import { useCore } from './hooks/use-core';

export const QRCodeGenerator: React.FC<QRCodeGeneratorProperties> = () => {
  const { themeContainer, tabContainer, errorContainer } = styles;

  const { error, state, activeTab } = useCore();

  const handleTabChange = HandleTabChange();

  return (
    <div style={themeContainer}>
      <div style={tabContainer}>
        <ThemeToggle />
        <TabNav handleTabChange={handleTabChange} />
        <TabRenderer tab={activeTab} />
        {error && <div style={errorContainer}>{error}</div>}
        <GenerateButtonsSection />
        {QRSection(state)}
      </div>
    </div>
  );
};

export const WrappedQRCodeGenerator = () => (
  <>
    <h2>QR Code Generator</h2>
    <ThemeProvider>
      <ErrorBoundary>
        <CoreProvider>
          <QRCodeGenerator />
          <Links />
        </CoreProvider>
      </ErrorBoundary>
    </ThemeProvider>
  </>
);
