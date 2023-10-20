import {QRCodeGeneratorState} from "../../ts/interfaces/qr-code-generator-state";
import {styles} from "../../assets/styles";
import React from "react";

export function QRSection(state: QRCodeGeneratorState) {
    const {qrCodeContainer} = styles;
    return <>
        {
            state.qrCodeURL &&
            <div style={qrCodeContainer}>
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
