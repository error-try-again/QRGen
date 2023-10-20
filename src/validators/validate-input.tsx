import {Tabs} from "../ts/enums/tabs-enum";
import {resetBatchAndLoadingState} from "../helpers/reset-loading-state";
import {areValidCcBcc} from "../utils/are-valid-cc-bcc.tsx";
import {requiredFieldsMapping} from "./validation-mapping.tsx";
import {ValidateInputParameters} from "../ts/interfaces/component-interfaces.tsx";

export function ValidateInput({activeTab, state, setError, setBatchData, setQrBatchCount, dispatch}: ValidateInputParameters) {
    return () => {

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
                if (state.cc && !areValidCcBcc({emails: state.cc})) {
                    setError("One or more CC emails are invalid");
                    resetBatchAndLoadingState({dispatch: dispatch, setBatchData: setBatchData, setQrBatchCount: setQrBatchCount});
                    return false;
                }
                if (state.bcc && !areValidCcBcc({emails: state.bcc})) {
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
