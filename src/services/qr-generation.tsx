import {Tabs} from "../ts/enums/tabs-enum";
import {resetBatchAndLoadingState} from "../helpers/reset-loading-state";
import {HandleSingleResponse} from "../responses/handle-single-response";
import {ValidateInput} from "../validators/validate-input";
import {HandleFetchError} from "../helpers/handle-fetch-error";
import {HandleErrorResponse} from "../responses/handle-error-response";
import {HandleBatchResponse} from "../responses/handle-batch-response";
import {QRGenerationParameters} from "../ts/interfaces/component-interfaces";

export function QRGeneration({
                                 dispatch,
                                 qrBatchCount,
                                 batchData,
                                 state,
                                 activeTab,
                                 setError,
                                 setBatchData,
                                 setQrBatchCount
                             }: QRGenerationParameters) {

    const validateInput = ValidateInput({activeTab: activeTab, dispatch: dispatch, setBatchData: setBatchData, setError: setError, setQrBatchCount: setQrBatchCount, state: state});
    const handleSingleResponse = HandleSingleResponse({dispatch: dispatch, setBatchData: setBatchData, setError: setError, setQrBatchCount: setQrBatchCount});
    const handleFetchError = HandleFetchError({dispatch: dispatch, setBatchData: setBatchData, setError: setError, setQrBatchCount: setQrBatchCount});
    const handleErrorResponse = HandleErrorResponse({dispatch: dispatch, setBatchData: setBatchData, setError: setError, setQrBatchCount: setQrBatchCount});
    const handleBatchResponse = HandleBatchResponse({dispatch: dispatch, setBatchData: setBatchData, setError: setError, setQrBatchCount: setQrBatchCount});

    return async () => {
        if (!validateInput()) {
            resetBatchAndLoadingState({setBatchData : setBatchData, setQrBatchCount : setQrBatchCount, dispatch : dispatch});
            return;
        }

        dispatch({type: 'SET_LOADING', value: true});

        const isBatch = qrBatchCount > 1;
        const endpoint = isBatch ? '/qr/batch' : '/qr/generate';

        //Form server payload
        const requestData = isBatch ? {qrCodes: batchData} : {
            size: state.size,
            precision: state.precision,
            type: Tabs[activeTab],
            customData: {
                ...state,
            }
        };

        try {

            const response = await fetch(endpoint, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(requestData)
            });

            if (!response.ok) {
                await handleErrorResponse(response);
                resetBatchAndLoadingState({setBatchData : setBatchData, setQrBatchCount : setQrBatchCount, dispatch : dispatch});
                return;
            }

            if (response.status === 429) {
                setError('You have exceeded the rate limit. Please try again later.');
                resetBatchAndLoadingState({setBatchData : setBatchData, setQrBatchCount : setQrBatchCount, dispatch : dispatch});
                return;
            }

            isBatch ? await handleBatchResponse(response) : await handleSingleResponse(response);

        } catch (error: unknown) {
            if (error instanceof Error) {
                handleFetchError();
                resetBatchAndLoadingState({setBatchData : setBatchData, setQrBatchCount : setQrBatchCount, dispatch : dispatch});
            } else {
                setError("Unknown error.");
                resetBatchAndLoadingState({setBatchData : setBatchData, setQrBatchCount : setQrBatchCount, dispatch : dispatch});
            }
        }
    };
}
