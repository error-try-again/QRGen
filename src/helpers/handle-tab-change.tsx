import {Tabs} from "../ts/enums/tabs-enum";
import {resetBatchAndLoadingState} from "./reset-loading-state";
import {HandleTabChangeParameters} from "../ts/interfaces/component-interfaces";

export function HandleTabChange({setError, setBatchData, setQrBatchCount, dispatch, setTab}: HandleTabChangeParameters) {
    return (freshTab: Tabs) => {
        setError("");
        resetBatchAndLoadingState({setBatchData : setBatchData, setQrBatchCount : setQrBatchCount, dispatch : dispatch});
        dispatch({type: 'SET_QRCODE_URL', value: ""});
        dispatch({type: 'RESET_STATE'});
        setTab(freshTab);
    };
}
