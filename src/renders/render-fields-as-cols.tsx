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

    return (fields: (keyof QRCodeRequest)[], columns: number) => {

        // Calculate the number of fields that should be in each column.
        // This is done by dividing the total number of fields by the number of columns
        // and rounding up to ensure all fields are accommodated.
        const colLength = Math.ceil(fields.length / columns);

        /**
         * 1. We start by creating an array of a specified length (`columns`).
         * 2. This array is filled with zeroes to ensure each slot has a value. This is necessary because `.map` won't iterate over 'undefined' values.
         * Mapping over each column, we use the current column index (`colIndex`) to calculate the start and end indices for slicing the `fields` array.
         * Then, Slice the `fields` array to get the portion of the fields that belong to the current column.
         * 3. The result is an array of arrays (`cols`) where each inner array represents a column and contains a subset of the `fields` that should be displayed in that column.
         */
        const cols = Array.from({length: columns}).fill(0).map((_, colIndex) =>
            fields.slice(colIndex * colLength, (colIndex + 1) * colLength)
        );

        // Return a JSX structure that represents the columns.
        return (
            // Flex container to layout child divs (columns) in a row.
            <div style={styles.renderBizCardsContainer}>
                {
                    // For each column (represented by colFields), render the fields.
                    cols.map((colFields, index) => (
                        <div key={index} style={{flex: 1, minWidth: `${100 / columns}%`}}>
                            {
                                // Render each field inside the column.
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
    };
}
