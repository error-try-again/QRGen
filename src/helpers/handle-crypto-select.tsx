import React from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types";

interface HandleCryptoSelectParameters {
    setSelectedCrypto: (value: (((previousState: string) => string) | string)) => void;
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
}

export function handleCryptoSelect({setSelectedCrypto, dispatch}: HandleCryptoSelectParameters) {
    return (cryptoType: string) => {
        setSelectedCrypto(cryptoType);
        dispatch({type: 'SET_FIELD', field: 'cryptoType', value: cryptoType});
    };
}
