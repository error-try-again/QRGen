import { ChangeEvent, useCallback } from 'react';
import { QRCodeRequest } from '../ts/interfaces/qr-code-request-interfaces';
import { useCore } from '../hooks/use-core.tsx';

export function HandleInputChange() {
  const { dispatch, state } = useCore();
  return useCallback(
    (
      event: ChangeEvent<
        HTMLElement & {
          value: string;
        }
      >,
      fieldName: keyof QRCodeRequest
    ) => {
      const value = event.target.value;
      if (state[fieldName] !== value) {
        dispatch({
          type: 'SET_FIELD',
          field: fieldName,
          value
        });
      }
    },
    [dispatch, state]
  );
}
