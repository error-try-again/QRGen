import { DESKTOP_MEDIA_QUERY_THRESHOLD } from '../constants/constants';
import { RenderFieldsInColumns } from './render-fields-as-cols';
import { ChangeEvent } from 'react';
import { QRCodeRequest } from '../ts/interfaces/qr-code-request-interfaces';

interface ResponsiveRendererProperties {
  handleInputChange: (
    event: ChangeEvent<HTMLTextAreaElement> | ChangeEvent<HTMLInputElement>,
    fieldName: keyof QRCodeRequest
  ) => void;
  fields: (keyof QRCodeRequest)[];
}

export const ResponsiveRenderer = ({
  handleInputChange,
  fields
}: ResponsiveRendererProperties) => {
  return window.innerWidth >= DESKTOP_MEDIA_QUERY_THRESHOLD ? (
    <RenderFieldsInColumns
      handleInputChange={handleInputChange}
      fields={fields}
      columns={2}
    />
  ) : (
    <RenderFieldsInColumns
      handleInputChange={handleInputChange}
      fields={fields}
      columns={1}
    />
  );
};
