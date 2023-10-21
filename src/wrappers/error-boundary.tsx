import React from 'react';
import { ErrorBoundaryProperties } from '../ts/interfaces/util-interfaces';

export class ErrorBoundary extends React.Component<ErrorBoundaryProperties> {
  override state = { hasError: false };

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  override componentDidCatch = (error: Error, errorInfo: React.ErrorInfo) => {
    console.error('ErrorBoundary caught an error', error, errorInfo);
  };

  override render() {
    if (this.state.hasError) {
      return (
        <div>
          <h1>Something went wrong. Please try again later.</h1>
          <a href="/report-error">Report this error</a>
        </div>
      );
    }
    return this.props.children;
  }
}
