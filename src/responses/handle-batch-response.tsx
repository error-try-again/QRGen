import { resetBatchAndLoadingState } from '../helpers/reset-loading-state';
import { HandleResponseParameters } from '../ts/interfaces/component-interfaces';

export function HandleBatchResponse({
  setError,
  setBatchData,
  setQrBatchCount,
  dispatch
}: HandleResponseParameters) {
  return async (response: Response) => {
    // Convert the ReadableStream to a Blob.
    const blob = await response.blob();
    const href = window.URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = href;

    // Extract the filename from the content-disposition header and set the download attribute
    const contentDisposition = response.headers.get('content-disposition');
    let filename = 'qrcodes.zip'; // default value
    if (contentDisposition) {
      const matches = contentDisposition.match(
        /filename[^\n;=]*=((["']).*?\2|[^\n;]*)/
      );
      if (matches && matches[1]) {
        filename = matches[1].replaceAll(/["']/g, ''); // remove any quotes
      }
    }
    link.download = filename;

    // Append the link, trigger download, and then remove the link
    document.body.append(link);
    link.click();
    link.remove();

    setError('');
    resetBatchAndLoadingState({
      setBatchData: setBatchData,
      setQrBatchCount: setQrBatchCount,
      dispatch: dispatch
    });
  };
}
