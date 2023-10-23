import { CryptoTypeField } from '../ts/interfaces/field-interfaces';
import { useCore } from '../hooks/use-core.tsx';

export function HandleCryptoChange(cryptoType: CryptoTypeField) {
  const { dispatch, setSelectedCrypto } = useCore();

  setSelectedCrypto(cryptoType.cryptoType);
  dispatch({
    field: 'cryptoType',
    type: 'SET_FIELD',
    value: cryptoType.cryptoType
  });
}
