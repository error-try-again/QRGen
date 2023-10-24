import { describe, expect, test } from 'vitest';
import { render, screen } from '@testing-library/react';
import { WrappedQRCodeGenerator } from '../qr-code-generator';
import '@testing-library/jest-dom/extend-expect';
import '@testing-library/jest-dom';

describe('QR Render Test', () => {
  test('Should Render App', () => {
    render(<WrappedQRCodeGenerator />);
    expect(screen.getByText('QR Code Generator')).toBeInTheDocument();
  });
});
