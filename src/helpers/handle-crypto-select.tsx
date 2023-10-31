import { CryptoTypeField } from '../ts/interfaces/field-interfaces';
import { HandelCryptoSelectParameters } from '../ts/interfaces/component-interfaces.tsx';

export function handleCryptoSelect({
  dispatch,
  setSelectedCrypto
}: HandelCryptoSelectParameters) {
  return ({ cryptoType }: CryptoTypeField) => {
    setSelectedCrypto(cryptoType);
    dispatch({
      field: 'cryptoType',
      type: 'SET_FIELD',
      value: cryptoType
    });
  };
}
