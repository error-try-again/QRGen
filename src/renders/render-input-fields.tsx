import {QRCodeGeneratorState} from "../ts/interfaces/qr-code-generator-state.tsx";
import React from "react";
import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces.tsx";

import {HandleInputChange} from "../callbacks/handle-input-change.tsx";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types.tsx";
import {InputField} from "../components/fields/input-field.tsx";
import {convertValueToString} from "../utils/convert-to-string.tsx";

export function RenderInputFields(
    state: QRCodeGeneratorState,
    dispatch: React.Dispatch<QRCodeGeneratorAction>,
    setError: (value: (((previousState: string) => string) | string)) => void) {

    const handleInputChange = HandleInputChange(state, dispatch);

    function RenderedInputFields(keys: (keyof QRCodeRequest)[]) {
        return <>
            {keys.map(key => {
                const convertedValue = convertValueToString(state[key]);
                return (
                    <InputField key={key.toString()}
                                keyName={key}
                                value={convertedValue}
                                handleChange={handleInputChange}
                                setError={setError}/>
                );
            })}
            {() => setError("")}
        </>;
    }

    RenderedInputFields.displayName = "RenderedInputFields";

    return RenderedInputFields;
}
