import {styles} from "../../assets/styles";
import * as React from "react";
import {ChangeEvent} from "react";
import {convertValueToString} from "../../utils/convert-to-string";
import {InputFieldParameters} from "../../ts/interfaces/component-interfaces";

export const InputFieldComponent: React.FC<InputFieldParameters> = React.memo(({
                                                                                   isRequired = false,
                                                                                   keyName,
                                                                                   value,
                                                                                   type = "text",
                                                                                   setError,
                                                                                   handleChange
                                                                               }) => {

    const {input, label, fieldContainer} = styles;

    const friendlyKeyName = keyName.charAt(0).toUpperCase() + keyName.slice(1).replaceAll(/([A-Z])/g, ' $1'); // Converts "cryptoType" to "Crypto Type"
    const convertedValue = convertValueToString({value: value});

    return (
        <div style={fieldContainer}>
            <label style={label} htmlFor={String(keyName)}>Enter {friendlyKeyName}</label>
            <input
                required={isRequired}
                type={type}
                id={String(keyName)}
                style={input}
                value={convertedValue}
                onChange={(event: ChangeEvent<HTMLInputElement>) => handleChange(event, keyName)}
                onFocus={() => setError("")}
                placeholder={`Enter ${friendlyKeyName}` + (isRequired ? " *" : "")}
            />
        </div>
    );
});

InputFieldComponent.displayName = "InputField";
export const InputField = React.memo(InputFieldComponent);
