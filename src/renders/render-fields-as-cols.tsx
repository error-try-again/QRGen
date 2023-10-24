import { QRCodeRequest } from '../ts/interfaces/qr-code-request-interfaces';
import { useCore } from '../hooks/use-core';
import { requiredFieldsMapping } from '../validators/validation-mapping';
import { styles } from '../assets/styles';
import { InputField } from '../components/fields/input-field';
import { ChangeEvent } from 'react';

export type RenderFieldsInColumnsProperties = {
  fields: (keyof QRCodeRequest)[];
  columns: number;
  handleInputChange: (
    event: ChangeEvent<HTMLTextAreaElement> | ChangeEvent<HTMLInputElement>,
    fieldName: keyof QRCodeRequest
  ) => void;
};

export const RenderFieldsInColumns = ({
  fields,
  columns,
  handleInputChange
}: RenderFieldsInColumnsProperties) => {
  const { state, setError, activeTab } = useCore();

  function isFieldRequired(fieldName: keyof QRCodeRequest): boolean {
    const requiredFields = requiredFieldsMapping[activeTab]?.fields || [];
    return requiredFields.includes(fieldName as string);
  }

  const { renderBizCardsContainer } = styles;

  const colLength = Math.ceil(fields.length / columns);
  const cols = Array.from({ length: columns })
    .fill(0)
    .map((_, colIndex) =>
      fields.slice(colIndex * colLength, (colIndex + 1) * colLength)
    );

  return (
    <div style={renderBizCardsContainer}>
      {cols.map((colFields, index) => (
        <div
          key={index}
          style={{ flex: 1, minWidth: `${100 / columns}%` }}
        >
          {colFields.map(key => (
            <InputField
              isRequired={isFieldRequired(key)}
              key={key.toString()}
              keyName={key}
              value={state[key]}
              handleChange={handleInputChange}
              setError={setError}
            />
          ))}
        </div>
      ))}
    </div>
  );
};
