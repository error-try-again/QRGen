import {QRCodeGeneratorState} from "../../ts/interfaces/qr-code-generator-state.tsx";
import {styles} from "../../assets/styles.tsx";
import React from "react";

export function QRSection(state: QRCodeGeneratorState) {
    return <>
        {
            state.qrCodeURL &&
            <div style={styles.qrCodeContainer}>
                <img src={state.qrCodeURL}
                     alt="Generated QR Code"
                     style={{width: `${state.size}px`, height: `${state.size}px`}}
                     onError={(event: React.SyntheticEvent<HTMLImageElement>) => console.error('Image Error:', event)}
                />
                <a href={state.qrCodeURL} download="QRCode.png">
                    Download QR Code
                </a>
            </div>
        }
    </>;
}
