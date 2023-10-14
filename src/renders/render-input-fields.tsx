import {QRCodeGeneratorState} from "../ts/interfaces/qr-code-generator-state.tsx";
import React from "react";
import {QRCodeRequest} from "../ts/interfaces/qr-code-request-types.tsx";
import {convertValueToString} from "../utils/convert-to-string.tsx";
import {InputField} from "../components/input-field.tsx";

export function RenderInputFields(state: QRCodeGeneratorState, handleInputChange: (event: React.ChangeEvent<HTMLElement & { value: string }>, fieldName: keyof QRCodeRequest) => void, setError: (value: (((previousState: string) => string) | string)) => void) {
    return (keys: (keyof QRCodeRequest)[]) => {
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
    };
}
