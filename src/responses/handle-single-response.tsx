import { resetBatchAndLoadingState } from '../helpers/reset-loading-state';
import { HandleResponseParameters } from '../ts/interfaces/component-interfaces';

export const HandleSingleResponse =
  ({
    dispatch,
    setError,
    setBatchData,
    setQrBatchCount
  }: HandleResponseParameters) =>
  async (response: Response) => {
    const result = await response.json();
    dispatch({ type: 'SET_QRCODE_URL', value: result.qrCodeURL });
    setError('');
    resetBatchAndLoadingState({
      setBatchData: setBatchData,
      setQrBatchCount: setQrBatchCount,
      dispatch: dispatch
    });
  };
