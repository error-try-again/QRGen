import { HandleCryptoSelectParameters } from '../ts/interfaces/component-interfaces';
import { CryptoTypeField } from '../ts/interfaces/field-interfaces';

export function handleCryptoSelect({
  setSelectedCrypto,
  dispatch
}: HandleCryptoSelectParameters) {
  return ({ cryptoType }: CryptoTypeField) => {
    setSelectedCrypto(cryptoType);
    dispatch({
      field: 'cryptoType',
      type: 'SET_FIELD',
      value: cryptoType
    });
  };
}
