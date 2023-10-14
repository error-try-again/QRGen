import {QRCodeRequest} from "../ts/interfaces/qr-code-request-types.tsx";
import {styles} from "../assets/styles.tsx";
import * as React from "react";
import {ChangeEvent} from "react";
import {convertValueToString} from "../utils/convert-to-string.tsx";

export const InputField: React.FC<{
    keyName: keyof QRCodeRequest,
    value: string | boolean | null | undefined,
    type?: string,
    setError: React.Dispatch<React.SetStateAction<string | "">>,
    handleChange: (event: ChangeEvent<HTMLInputElement>, fieldName: keyof QRCodeRequest) => void
}> = React.memo(({keyName, value, type = 'text', handleChange, setError}) => {

    const friendlyKeyName = keyName.charAt(0).toUpperCase() + keyName.slice(1).replaceAll(/([A-Z])/g, ' $1'); // Converts "cryptoType" to "Crypto Type"
    const convertedValue = convertValueToString(value);

    return (
        <div style={styles.fieldContainer}>
            <label style={styles.label} htmlFor={String(keyName)}>Enter {friendlyKeyName}</label>
            <input
                type={type}
                id={String(keyName)}
                style={styles.input}
                value={convertedValue}
                onChange={(event: ChangeEvent<HTMLInputElement>) => handleChange(event, keyName)}
                onFocus={() => setError("")}
                placeholder={`Enter ${friendlyKeyName}`}
            />
        </div>
    );
});
