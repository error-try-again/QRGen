import {QRCodeGeneratorState} from "../ts/interfaces/qr-code-generator-state";
import React from "react";
import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces";

import {HandleInputChange} from "../callbacks/handle-input-change";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types";
import {InputField} from "../components/fields/input-field";
import {convertValueToString} from "../utils/convert-to-string";

interface InputFields {
    state: QRCodeGeneratorState;
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
    setError: (value: (((previousState: string) => string) | string)) => void;
}

export function RenderInputFields(
    {state, dispatch, setError}: InputFields) {

    const handleInputChange = HandleInputChange({state: state, dispatch: dispatch});

    function RenderedInputFields(keys: (keyof QRCodeRequest)[]) {
        return <>
            {keys.map(key => {
                const convertedValue = convertValueToString({value : state[key]});
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
