import {QRCodeGeneratorState} from "../ts/interfaces/qr-code-generator-state";
import React from "react";
import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces";
import {HandleInputChange} from "../callbacks/handle-input-change";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types";
import {InputField} from "../components/fields/input-field";
import {styles} from "../assets/styles";


interface FieldsAsColumns {
    state: QRCodeGeneratorState;
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
    setError: (value: (((previousState: string) => string) | string)) => void;
}

// Function to render the fields distributed across the specified number of columns.
export function RenderFieldsAsColumns(
    {state, dispatch, setError}: FieldsAsColumns,
) {
    const handleInputChange = HandleInputChange({state : state, dispatch : dispatch});

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
