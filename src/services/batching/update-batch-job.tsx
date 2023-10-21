import { Tabs } from '../../ts/enums/tabs-enum';
import { QRCodeRequest } from '../../ts/interfaces/qr-code-request-interfaces';
import { UpdateBatchJobParameters } from '../../ts/interfaces/component-interfaces';

export function UpdateBatchJob({
  state,
  activeTab,
  setQrBatchCount,
  setBatchData
}: UpdateBatchJobParameters) {
  return () => {
    const dataToBatch = { customData: { ...state }, type: Tabs[activeTab] };
    setBatchData((previousBatch: QRCodeRequest[]) => [
      ...previousBatch,
      dataToBatch
    ]);
    setQrBatchCount((previous: number) => previous + 1);
  };
}
