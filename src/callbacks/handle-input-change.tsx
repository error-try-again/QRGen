import {QRCodeGeneratorState} from "../ts/interfaces/qr-code-generator-state.tsx";
import React, {ChangeEvent, useCallback} from "react";
import {QRCodeGeneratorAction} from "../ts/types/reducer-types.tsx";
import {QRCodeRequest} from "../ts/interfaces/qr-code-request-types.tsx";

export function HandleInputChange(state: QRCodeGeneratorState, dispatch: React.Dispatch<QRCodeGeneratorAction>) {
    return useCallback((event: ChangeEvent<HTMLElement & {
        value: string
    }>, fieldName: keyof QRCodeRequest) => {
        const value = event.target.value;
        if (state[fieldName] !== value) {
            dispatch({type: 'SET_FIELD', field: fieldName, value});
        }
    }, [dispatch, state]);
}
