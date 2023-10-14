import React from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types.tsx";

export function handleCryptoSelect(setSelectedCrypto: (value: (((previousState: string) => string) | string)) => void, dispatch: React.Dispatch<QRCodeGeneratorAction>) {
    return (cryptoType: string) => {
        setSelectedCrypto(cryptoType);
        dispatch({type: 'SET_FIELD', field: 'cryptoType', value: cryptoType});
    };
}
