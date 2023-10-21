import { QRCodeRequest } from '../ts/interfaces/qr-code-request-interfaces';
import React from 'react';
import { QRCodeGeneratorAction } from '../ts/types/reducer-types';
import { QRCodeGeneratorState } from '../ts/interfaces/qr-code-generator-state.tsx';

export interface ResetBatchAndLoadingStateParameters {
  setBatchData: (
    value:
      | ((previousState: QRCodeRequest[]) => QRCodeRequest[])
      | QRCodeRequest[]
  ) => void;
  setQrBatchCount: (
    value: ((previousState: number) => number) | number
  ) => void;
  dispatch: React.Dispatch<QRCodeGeneratorAction>;
  initialState?: QRCodeGeneratorState;
}

export function dispatchInitialTabState({
  dispatch,
  initialState
}: {
  dispatch: React.Dispatch<QRCodeGeneratorAction>;
  initialState?: QRCodeGeneratorState;
}) {
  function handleInitialDispatch() {
    if (initialState) {
      if (initialState.cryptoType) {
        console.log('initialState.cryptoType', initialState.cryptoType);
        dispatch({
          type: 'SET_FIELD',
          field: 'cryptoType',
          value: initialState.cryptoType
        });
      } else if (initialState.version) {
        dispatch({
          type: 'SET_FIELD',
          field: 'version',
          value: initialState.version
        });
      }
    }
  }

  handleInitialDispatch();
}

export function resetBatchAndLoadingState({
  setBatchData,
  setQrBatchCount,
  dispatch
}: ResetBatchAndLoadingStateParameters) {
  function clear() {
    setBatchData([]);
    setQrBatchCount(0);
    dispatch({ type: 'SET_LOADING', value: false });
  }

  clear();
}
