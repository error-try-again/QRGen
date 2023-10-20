import {Tabs} from "../ts/enums/tabs-enum";
import {QRCodeGeneratorState} from "../ts/interfaces/qr-code-generator-state";
import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces";
import React from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types";
import {resetBatchAndLoadingState} from "../helpers/reset-loading-state";
import {areValidCcBcc} from "../utils/are-valid-cc-bcc.tsx";

export interface Input {
    activeTab: Tabs;
    state: QRCodeGeneratorState;
    setError: (value: (((previousState: string) => string) | string)) => void;
    setBatchData: (value: (((previousState: QRCodeRequest[]) => QRCodeRequest[]) | QRCodeRequest[])) => void;
    setQrBatchCount: (value: (((previousState: number) => number) | number)) => void;
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
}

export function ValidateInput({activeTab, state, setError, setBatchData, setQrBatchCount, dispatch}: Input) {
    return () => {
        const requiredFieldsMapping = {
            [Tabs.Text]: {fields: ['text'], errorMessage: "Text is required"},
            [Tabs.Url]: {fields: ['url'], errorMessage: "URL is required"},
            [Tabs.Email]: {fields: ['email'], errorMessage: "Email is required"},
            [Tabs.Phone]: {fields: ['phone'], errorMessage: "Phone is required"},
            [Tabs.WiFi]: {fields: ['ssid'], errorMessage: "SSID is required"},
            [Tabs.SMS]: {fields: ['phone', 'sms'], errorMessage: "Phone and SMS message are required"},
            [Tabs.Event]: {fields: ['event', 'venue', 'startTime', 'endTime'], errorMessage: "Event, Venue, Start Time and End Time are required"},
            [Tabs.GeoLocation]: {fields: ['latitude', 'longitude'], errorMessage: "Latitude and Longitude are required"},
            [Tabs.Crypto]: {fields: ['address'], errorMessage: "Address is required"},
            [Tabs.MeCard]: {fields: ['firstName', 'lastName', 'phone1'], errorMessage: "First Name, Last Name and Phone are required"},
            [Tabs.VCard]: {fields: ['firstName', 'lastName', 'email', 'phoneWork'], errorMessage: "First Name, Last Name, Email and Phone are required"},
            [Tabs.Zoom]: {fields: ['zoomId', 'zoomPass'], errorMessage: "Zoom Meeting ID and Password are required"},
        };

        const requiredFields = requiredFieldsMapping[activeTab];

        if (requiredFields) {
            for (const field of requiredFields.fields) {
                if (!state[field as keyof typeof state]) {
                    setError(requiredFields.errorMessage);
                    resetBatchAndLoadingState({dispatch: dispatch, setBatchData: setBatchData, setQrBatchCount: setQrBatchCount});
                    return false;
                }
            }
            if (activeTab === Tabs.Email) {
                if (state.cc && !areValidCcBcc({emails : state.cc})) {
                    setError("One or more CC emails are invalid");
                    resetBatchAndLoadingState({dispatch: dispatch, setBatchData: setBatchData, setQrBatchCount: setQrBatchCount});
                    return false;
                }
                if (state.bcc && !areValidCcBcc({emails : state.bcc})) {
                    setError("One or more BCC emails are invalid");
                    resetBatchAndLoadingState({dispatch: dispatch, setBatchData: setBatchData, setQrBatchCount: setQrBatchCount});
                    return false;
                }
            }
            return true;
        } else {
            return true;
        }
    };
}
