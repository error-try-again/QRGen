import {QRCodeRequest} from "../ts/interfaces/qr-code-request-types.tsx";
import {styles} from "../assets/styles.tsx";
import {ChangeEvent} from "react";
import * as React from "react";

export const DropdownField: React.FC<{
    keyName: keyof QRCodeRequest,
    options: string[],
    value: string | null | undefined,
    setError: React.Dispatch<React.SetStateAction<string | "">>,
    handleChange: (event: ChangeEvent<HTMLSelectElement>, fieldName: keyof QRCodeRequest) => void
}> = React.memo(({keyName, options, value, handleChange, setError}) => {
    const friendlyKeyName = keyName.charAt(0).toUpperCase() + keyName.slice(1).replaceAll(/([A-Z])/g, ' $1');
    return (
        <div style={styles.fieldContainer}>
            <label style={styles.label} htmlFor={String(keyName)}>Select {friendlyKeyName}</label>
            <select
                id={String(keyName)}
                style={styles.dropdown}
                value={value || ''}
                onChange={(event: React.ChangeEvent<HTMLSelectElement>) => {
                    handleChange(event, keyName);
                }}
                onFocus={() => setError("")}>
                <option value="">{`-- Choose ${friendlyKeyName} --`}</option>
                // Updated for clarity
                {options.map((option: string) => (<option key={option} value={option}>{option}</option>))}
            </select>
        </div>
    );
});
