import {HandleCryptoSelectParameters} from "../ts/interfaces/component-interfaces.tsx";
import {CryptoTypeField} from "../ts/interfaces/field-interfaces.tsx";

export function handleCryptoSelect({setSelectedCrypto, dispatch}: HandleCryptoSelectParameters) {
    return ({cryptoType}: CryptoTypeField) => {
        setSelectedCrypto(cryptoType);
        dispatch({
            field: 'cryptoType',
            type: 'SET_FIELD',
            value: cryptoType
        });
    };
}
