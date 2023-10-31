import { resetBatchAndLoadingState } from '../helpers/reset-loading-state';
import { HandleResponseParameters } from '../ts/interfaces/component-interfaces';

function dispatchQRCodeUrl(
  dispatch: (value: { type: 'SET_QRCODE_URL'; value: string | null }) => void,
  qrCodeURL: string
) {
  dispatch({ type: 'SET_QRCODE_URL', value: qrCodeURL });
}

export const HandleSingleResponse =
  ({
    dispatch,
    setError,
    setBatchData,
    setQrBatchCount
  }: HandleResponseParameters) =>
  async (response: Response) => {
    const { qrCodeURL } = await response.json();
    dispatchQRCodeUrl(dispatch, qrCodeURL);
    setError('');
    resetBatchAndLoadingState({ dispatch, setBatchData, setQrBatchCount });
  };
