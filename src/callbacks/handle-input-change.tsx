import {QRCodeGeneratorState} from "../ts/interfaces/qr-code-generator-state";
import React, {ChangeEvent, useCallback} from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types";
import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces";

interface HandleInputChangeParameters {
    state: QRCodeGeneratorState;
    dispatch: React.Dispatch<QRCodeGeneratorAction>;
}

export function HandleInputChange({state, dispatch}: HandleInputChangeParameters) {
    return useCallback((event: ChangeEvent<HTMLElement & {
        value: string
    }>, fieldName: keyof QRCodeRequest) => {
        const value = event.target.value;
        if (state[fieldName] !== value) {
            dispatch({type: 'SET_FIELD', field: fieldName, value});
        }
    }, [dispatch, state]);
}
