import React from 'react';
import 'leaflet/dist/leaflet.css';
import { ThemeProvider } from './contexts/theme-context';
import { QRCodeGeneratorProperties } from './ts/interfaces/util-interfaces';
import { TabRenderMap } from './renders/all-tabs-render-map';
import { GenerateButtonsSection } from './components/buttons/generate-buttons-section';
import { ThemeToggle } from './components/theme/theme-toggle';
import { TabNav } from './components/nav/tab-nav';
import { QRSection } from './components/qr/qr-section';
import { ErrorBoundary } from './wrappers/error-boundary';
import { Links } from './components/links/links';
import { CoreProvider } from './contexts/core-context';
import { ErrorSection } from './components/errors/error-section';
import { SectionWrapper } from './components/containers/section-container';
import { Title } from './components/header/title';

export const QRCodeGenerator: React.FC<QRCodeGeneratorProperties> = () => {
  return (
    <SectionWrapper>
      <ThemeToggle />
      <TabNav />
      <TabRenderMap />
      <ErrorSection />
      <GenerateButtonsSection />
      <QRSection />
    </SectionWrapper>
  );
};

export const WrappedQRCodeGenerator = () => (
  <>
    <ThemeProvider>
      <ErrorBoundary>
        <Title />
        <CoreProvider>
          <QRCodeGenerator />
          <Links />
        </CoreProvider>
      </ErrorBoundary>
    </ThemeProvider>
  </>
);
