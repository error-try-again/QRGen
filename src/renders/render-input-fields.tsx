import { QRCodeRequest } from '../ts/interfaces/qr-code-request-interfaces';
import { useHandleInputChange } from '../hooks/callbacks/use-handle-input-change';
import { InputField } from '../components/fields/input-field';
import { convertValueToString } from '../utils/convert-to-string';
import { useCore } from '../hooks/use-core';
import { isKeyRequired } from '../helpers/is-key-required';

export const InputFields = ({ keys }: { keys: (keyof QRCodeRequest)[] }) => {
  const { state, setError, activeTab } = useCore();
  const handleInputChange = useHandleInputChange();

  return (
    <>
      {keys.map(key => (
        <InputField
          key={key.toString()}
          keyName={key}
          value={convertValueToString({ value: state[key] })}
          handleChange={handleInputChange}
          setError={setError}
          isRequired={isKeyRequired(activeTab, key)}
        />
      ))}
    </>
  );
};
