import React from 'react';
import 'leaflet/dist/leaflet.css';
import { styles } from './assets/styles';
import { ThemeProvider } from './contexts/theme-context';
import { QRCodeGeneratorProperties } from './ts/interfaces/util-interfaces';
import { HandleTabChange } from './helpers/handle-tab-change';
import { RenderAllTabs } from './renders/render-all-tabs';
import { GenerateButtonsSection } from './components/buttons/generate-buttons-section';
import { ThemeToggle } from './components/theme/theme-toggle';
import { TabNav } from './components/tabs/tab-nav';
import { QRSection } from './components/qr/qr-section';
import { ErrorBoundary } from './wrappers/error-boundary';
import { Links } from './components/links/links';
import { CoreProvider } from './contexts/core-context';
import { useCore } from './hooks/use-core';

const QrCodeGenerator: React.FC<QRCodeGeneratorProperties> = () => {
  const { themeContainer, tabContainer, errorContainer } = styles;

  const { state, error, activeTab } = useCore();

  const handleTabChange = HandleTabChange();
  const TabSections = RenderAllTabs({ tab: activeTab });

  return (
    <div style={themeContainer}>
      <div style={tabContainer}>
        <ThemeToggle />
        <TabNav handleTabChange={handleTabChange} />
        {TabSections[activeTab]?.()}
        {error && <div style={errorContainer}>{error}</div>}
        <GenerateButtonsSection />
        {QRSection(state)}
      </div>
    </div>
  );
};

const WrappedQRCodeGenerator = () => (
  <ThemeProvider>
    <ErrorBoundary>
      <CoreProvider>
        <QrCodeGenerator />
        <Links />
      </CoreProvider>
    </ErrorBoundary>
  </ThemeProvider>
);

export { WrappedQRCodeGenerator as QRCodeGenerator };
