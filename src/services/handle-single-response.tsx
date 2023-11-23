import {resetBatchAndLoadingState} from '../helpers/reset-loading-state.tsx';
import {HandleResponseParameters} from '../ts/interfaces/component-interfaces.tsx';
import {processSingleQRCode} from "./qr-code-controller.tsx";


function dispatchQRCodeUrl(
    dispatch: (value: { type: 'SET_QRCODE_URL'; value: string | null }) => void,
    qrCodeURL: string
) {
    dispatch({type: 'SET_QRCODE_URL', value: qrCodeURL});
}

export const HandleSingleResponse =
    ({
         dispatch,
         setError,
         setBatchData,
         setQrBatchCount
     }: HandleResponseParameters) =>
        async (data: any) => {

            await processSingleQRCode({qrData: data}).then((qrCodeData) => {
                dispatchQRCodeUrl(dispatch, qrCodeData.qrCodeData);
            });

            setError('');
            resetBatchAndLoadingState({
                dispatch,
                setBatchData,
                setQrBatchCount
            });

        };
