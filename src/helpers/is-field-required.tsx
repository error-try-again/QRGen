import { Tabs } from '../ts/enums/tabs-enum';
import { requiredFieldsMapping } from '../validators/validation-mapping';

export const isFieldRequired = (
  activeTab: Tabs,
  fieldName: string
): boolean => {
  const tabMapping = requiredFieldsMapping[activeTab];
  const requiredFields = tabMapping ? tabMapping.fields : [];
  return requiredFields.includes(fieldName);
};
