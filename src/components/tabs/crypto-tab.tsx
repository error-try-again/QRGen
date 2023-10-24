import { styles } from '../../assets/styles';
import { useHandleInputChange } from '../../hooks/callbacks/use-handle-input-change';
import { useCore } from '../../hooks/use-core';
import { Divider } from '../extras/divider';
import { CRYPTO_TYPES } from '../../constants/constants';
import { InputField } from '../fields/input-field';
import { isFieldRequired } from '../../helpers/is-field-required';
import { Tabs } from '../../ts/enums/tabs-enum';
import { HandleCryptoChange } from '../../helpers/handle-crypto-select';

export const CryptoTab = () => {
  const { sectionTitle, section } = styles;
  const handleInputChange = useHandleInputChange();
  const { state, setError, selectedCrypto } = useCore();
  return (
    <section style={section}>
      <h2 style={sectionTitle}>Crypto</h2>
      <Divider />
      {CRYPTO_TYPES.map(cryptoType => (
        <div key={cryptoType}>
          <input
            type="radio"
            id={cryptoType}
            name="cryptoType"
            value={cryptoType}
            checked={cryptoType === selectedCrypto}
            onChange={() => HandleCryptoChange({ cryptoType })}
          />
          <label htmlFor={cryptoType}> {cryptoType}</label>
          <br />
        </div>
      ))}
      {selectedCrypto && (
        <>
          <InputField
            isRequired={isFieldRequired(Tabs.Crypto, 'address')}
            keyName="address"
            value={state.address}
            handleChange={handleInputChange}
            setError={setError}
          />
          <InputField
            keyName="amount"
            value={state.amount}
            handleChange={handleInputChange}
            setError={setError}
          />
        </>
      )}
    </section>
  );
};
