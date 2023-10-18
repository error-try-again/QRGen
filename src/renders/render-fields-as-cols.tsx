import {QRCodeGeneratorState} from "../ts/interfaces/qr-code-generator-state.tsx";
import React from "react";
import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces.tsx";
import {HandleInputChange} from "../callbacks/handle-input-change.tsx";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types.tsx";
import {InputField} from "../components/fields/input-field.tsx";
import {styles} from "../assets/styles.tsx";

// Function to render the fields distributed across the specified number of columns.
// Parameters:
//   - fields: An array of field keys to be rendered.
//   - columns: The number of columns in which the fields should be distributed.
export function RenderFieldsAsColumns(
    state: QRCodeGeneratorState,
    dispatch: React.Dispatch<QRCodeGeneratorAction>,
    setError: (value: (((previousState: string) => string) | string)) => void,
) {
    const handleInputChange = HandleInputChange(state, dispatch);

    function RenderedInputColumns(fields: (keyof QRCodeRequest)[], columns: number) {

        const colLength = Math.ceil(fields.length / columns);
        const cols = Array.from({length: columns}).fill(0).map((_, colIndex) =>
            fields.slice(colIndex * colLength, (colIndex + 1) * colLength)
        );

        const {renderBizCardsContainer} = styles;
        return (
            <div style={renderBizCardsContainer}>
                {
                    cols.map((colFields, index) => (
                        <div key={index} style={{flex: 1, minWidth: `${100 / columns}%`}}>
                            {
                                colFields.map(key => (
                                    <InputField
                                        key={key.toString()}
                                        keyName={key}
                                        value={state[key]}
                                        handleChange={handleInputChange}
                                        setError={setError}
                                    />
                                ))
                            }
                        </div>
                    ))
                }
            </div>
        );
    }

    RenderedInputColumns.displayName = "RenderedInputColumns";

    return RenderedInputColumns;
}
