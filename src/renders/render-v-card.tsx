import {QRCodeGeneratorState} from "../ts/interfaces/qr-code-generator-state";
import React from "react";
import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces";
import {styles} from "../assets/styles";
import {DESKTOP_MEDIA_QUERY_THRESHOLD} from "../constants/constants";
import {VCardFields} from "../constants/fields";
import {HandleInputChange} from "../callbacks/handle-input-change";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types";

interface VCard {
    state: QRCodeGeneratorState;
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
    renderInputFieldsInColumns: (fields: (keyof QRCodeRequest)[], columns: number) => React.JSX.Element;
}

export function renderVCard(
    {state, dispatch, renderInputFieldsInColumns}: VCard) {

    const handleInputChange = HandleInputChange({state : state, dispatch : dispatch});

    function RenderedVCard() {
        const {label, fieldContainer} = styles;
        return (
            <>
                <div style={fieldContainer}>
                    <p style={label}>vCard Version</p>
                    {
                        // Render radio buttons for each vCard version.
                        ['2.1', '3.0', '4.0'].map(version => (
                            <div key={version}>
                                <input type="radio"
                                       id={`version_${version}`}
                                       name="version"
                                       value={version}
                                       checked={state.version === version}
                                       onChange={(event: React.ChangeEvent<HTMLInputElement>) => handleInputChange(event, 'version')}
                                />
                                <label htmlFor={`version_${version}`}> {version}</label>
                            </div>
                        ))
                    }
                </div>
                {
                    // Check the current viewport width.
                    // If it's larger or equal to the DESKTOP_MEDIA_QUERY_THRESHOLD, use 2 columns, otherwise use 1 column.
                    window.innerWidth >= DESKTOP_MEDIA_QUERY_THRESHOLD
                        ? renderInputFieldsInColumns(VCardFields, 2) // For wider screens (desktop)
                        : renderInputFieldsInColumns(VCardFields, 1) // For narrower screens (mobile)
                }
            </>
        );
    }

    RenderedVCard.displayName = "RenderedVCard";

    return RenderedVCard;
}
