import { Tabs } from '../ts/enums/tabs-enum';
import { QRCodeRequest } from '../ts/interfaces/qr-code-request-interfaces';
import { requiredFieldsMapping } from '../validators/validation-mapping';

export const isKeyRequired = (
  activeTab: Tabs,
  fieldName: keyof QRCodeRequest
): boolean => {
  const requiredFields = requiredFieldsMapping[activeTab]?.fields || [];
  return requiredFields.includes(fieldName as string);
};
