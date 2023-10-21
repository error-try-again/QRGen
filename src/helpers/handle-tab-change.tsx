import { Tabs } from '../ts/enums/tabs-enum';
import { resetBatchAndLoadingState } from './reset-loading-state';
import { useCore } from '../hooks/use-core';
import { initialState } from '../constants/constants.tsx';

export function HandleTabChange() {
  const {
    dispatch,
    setError,
    setBatchData,
    setQrBatchCount,
    setActiveTab,
    activeTab
  } = useCore();

  return (freshTab: Tabs) => {
    const init = { ...initialState };

    if (activeTab === Tabs.Crypto) {
      // Set the crypto type to bitcoin
      init.cryptoType = 'bitcoin';
    }
    if (activeTab === Tabs.VCard) {
      // Set the version to 3.0
      init.version = '3.0';
    }

    setError('');
    resetBatchAndLoadingState({
      setBatchData: setBatchData,
      setQrBatchCount: setQrBatchCount,
      dispatch: dispatch,
      initialState: init
    });
    setActiveTab(freshTab);
  };
}
