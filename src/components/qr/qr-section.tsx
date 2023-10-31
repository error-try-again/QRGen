import { styles } from '../../assets/styles';
import React from 'react';
import { useCore } from '../../hooks/use-core';

export const QRSection = () => {
  const { qrCodeContainer } = styles;

  const {
    state: { qrCodeURL, size }
  } = useCore();

  return (
    <>
      {qrCodeURL && (
        <div style={qrCodeContainer}>
          <img
            src={qrCodeURL}
            alt="Generated QR Code"
            style={{ width: `${size}px`, height: `${size}px` }}
            onError={(event: React.SyntheticEvent<HTMLImageElement>) =>
              console.error('Image Error:', event)
            }
          />
          <a
            href={qrCodeURL}
            download="QRCode.png"
          >
            Download QR Code
          </a>
        </div>
      )}
    </>
  );
};
