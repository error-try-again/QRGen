import { QRCodeRequest } from '../ts/interfaces/qr-code-request-interfaces';
import { HandleInputChange } from '../callbacks/handle-input-change';
import { InputField } from '../components/fields/input-field';
import { convertValueToString } from '../utils/convert-to-string';
import { requiredFieldsMapping } from '../validators/validation-mapping';
import { useCore } from '../hooks/use-core.tsx';

export function RenderInputFields(keys: (keyof QRCodeRequest)[]) {
  const { state, setError, activeTab } = useCore();
  const handleInputChange = HandleInputChange();

  function isFieldRequired(fieldName: keyof QRCodeRequest): boolean {
    const requiredFields = requiredFieldsMapping[activeTab]?.fields || [];
    return requiredFields.includes(fieldName as string);
  }

  return (
    <>
      {keys.map(key => {
        const convertedValue = convertValueToString({ value: state[key] });
        const required = isFieldRequired(key);
        return (
          <InputField
            key={key.toString()}
            keyName={key}
            value={convertedValue}
            handleChange={handleInputChange}
            setError={setError}
            isRequired={required}
          />
        );
      })}
      {setError('')}
    </>
  );
}
