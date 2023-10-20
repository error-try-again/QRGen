import {resetBatchAndLoadingState} from "../helpers/reset-loading-state";
import {HandleResponseParameters} from "../ts/interfaces/component-interfaces.tsx";


export function HandleBatchResponse({setError, setBatchData, setQrBatchCount, dispatch}: HandleResponseParameters) {
    return async (response: Response) => {

        // Convert the ReadableStream to a Blob.
        const blob = await response.blob();
        const href = window.URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = href;
        link.download = response.headers.get("content-disposition")?.split('filename=')[1] || "qrcodes.zip"; // Use the filename from the response or default to 'download.zip'
        document.body.append(link);
        link.click();
        link.remove();

        setError("");
        resetBatchAndLoadingState({setBatchData : setBatchData, setQrBatchCount : setQrBatchCount, dispatch : dispatch});
    };

}
