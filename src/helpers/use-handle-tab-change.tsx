import { Tabs } from '../ts/enums/tabs-enum';
import { resetBatchAndLoadingState } from './reset-loading-state';
import { useCore } from '../hooks/use-core';

function dispatchClearQRCodeUrl(
  dispatch: (value: { type: 'SET_QRCODE_URL'; value: string | null }) => void
) {
  dispatch({ type: 'SET_QRCODE_URL', value: '' });
}

export function useHandleTabChange() {
  const {
    dispatch: dispatch,
    setError: setError,
    setBatchData: setBatchData,
    setQrBatchCount: setQrBatchCount,
    setActiveTab: setActiveTab
  } = useCore();

  return (freshTab: Tabs) => {
    dispatchClearQRCodeUrl(dispatch);
    setError('');
    resetBatchAndLoadingState({ setBatchData, setQrBatchCount, dispatch });
    setActiveTab(freshTab);
  };
}
