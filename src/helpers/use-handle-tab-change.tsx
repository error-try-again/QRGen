import { Tabs } from '../ts/enums/tabs-enum';
import { resetBatchAndLoadingState } from './reset-loading-state';
import { useCore } from '../hooks/use-core';

export function useHandleTabChange() {
  const {
    dispatch: dispatch,
    setError: setError,
    setBatchData: setBatchData,
    setQrBatchCount: setQrBatchCount,
    setActiveTab: setActiveTab
  } = useCore();

  return (freshTab: Tabs) => {
    setError('');
    resetBatchAndLoadingState({
      setBatchData: setBatchData,
      setQrBatchCount: setQrBatchCount,
      dispatch: dispatch
    });
    setActiveTab(freshTab);
  };
}
