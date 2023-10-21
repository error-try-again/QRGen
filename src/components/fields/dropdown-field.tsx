import { QRCodeRequest } from '../../ts/interfaces/qr-code-request-interfaces';
import { styles } from '../../assets/styles';
import * as React from 'react';
import { ChangeEvent, memo } from 'react';

const DropdownFieldComponent: React.FC<{
  handleChange: (
    event: ChangeEvent<HTMLSelectElement>,
    fieldName: keyof QRCodeRequest
  ) => void;
  keyName: keyof QRCodeRequest;
  options: string[];
  setError: React.Dispatch<React.SetStateAction<string | ''>>;
  value: string | null | undefined;
}> = ({ keyName, options, value, handleChange, setError }) => {
  const friendlyKeyName =
    keyName.charAt(0).toUpperCase() +
    keyName.slice(1).replaceAll(/([A-Z])/g, ' $1');
  const { label, dropdown, fieldContainer } = styles;

  return (
    <div style={fieldContainer}>
      <label
        style={label}
        htmlFor={String(keyName)}
      >
        Select {friendlyKeyName}
      </label>
      <select
        id={String(keyName)}
        style={dropdown}
        value={value || ''}
        onChange={(event: React.ChangeEvent<HTMLSelectElement>) => {
          handleChange(event, keyName);
        }}
        onFocus={() => setError('')}
      >
        <option value="">{`-- Choose ${friendlyKeyName} --`}</option>
        {options.map((option: string) => (
          <option
            key={option}
            value={option}
          >
            {option}
          </option>
        ))}
      </select>
    </div>
  );
};

DropdownFieldComponent.displayName = 'DropdownField';

export const DropdownField = memo(DropdownFieldComponent);
