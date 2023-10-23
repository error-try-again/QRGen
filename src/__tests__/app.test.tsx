import { describe, expect, test } from 'vitest';
import { render, screen } from '@testing-library/react';
import { WrappedQRCodeGenerator } from '../qr-code-generator.tsx';
import '@testing-library/jest-dom/extend-expect';

describe('QR Render Test', () => {
  test('Should Render App', () => {
    render(<WrappedQRCodeGenerator />);
    expect(screen.getByText('QR Code Generator')).toBeInTheDocument();
  });
});
