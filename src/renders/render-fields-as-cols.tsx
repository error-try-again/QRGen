import { QRCodeRequest } from '../ts/interfaces/qr-code-request-interfaces';
import { HandleInputChange } from '../callbacks/handle-input-change';
import { InputField } from '../components/fields/input-field';
import { styles } from '../assets/styles';
import { requiredFieldsMapping } from '../validators/validation-mapping';
import { useCore } from '../hooks/use-core.tsx';

// Function to render the fields distributed across the specified number of columns.
export function RenderFieldsAsColumns() {
  const { state, setError, activeTab } = useCore();
  const handleInputChange = HandleInputChange();

  function isFieldRequired(fieldName: keyof QRCodeRequest): boolean {
    const requiredFields = requiredFieldsMapping[activeTab]?.fields || [];
    return requiredFields.includes(fieldName as string);
  }

  function RenderedInputColumns(
    fields: (keyof QRCodeRequest)[],
    columns: number
  ) {
    const colLength = Math.ceil(fields.length / columns);
    const cols = Array.from({ length: columns })
      .fill(0)
      .map((_, colIndex) =>
        fields.slice(colIndex * colLength, (colIndex + 1) * colLength)
      );

    const { renderBizCardsContainer } = styles;
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
  }

  RenderedInputColumns.displayName = 'RenderedInputColumns';

  return RenderedInputColumns;
}
