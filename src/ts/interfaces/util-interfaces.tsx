import { ReactNode } from 'react';

export interface QRCodeGeneratorProperties {
  children?: ReactNode;
}

export interface ErrorBoundaryProperties {
  children: ReactNode;
}

export interface DefaultUnknownParameters {
  value: unknown;
}
