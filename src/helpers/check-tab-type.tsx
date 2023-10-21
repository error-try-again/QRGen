import { Tabs } from '../ts/enums/tabs-enum';
import { initialState } from '../constants/constants';

export function setInitialTabState(activeTab: Tabs) {
  const init = { ...initialState };
  switch (activeTab) {
    case Tabs.Crypto: {
      init.cryptoType = 'bitcoin';
      break;
    }
    case Tabs.VCard: {
      init.version = '3.0';
      break;
    }
  }
  return init;
}
