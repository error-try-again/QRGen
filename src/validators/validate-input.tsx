import { Tabs } from '../ts/enums/tabs-enum';
import { resetBatchAndLoadingState } from '../helpers/reset-loading-state';
import { requiredFieldsMapping } from './validation-mapping';
import { ValidateInputParameters } from '../ts/interfaces/component-interfaces';
import { isInvalidEmail } from '../utils/is-invalid-email.tsx';
import { QRCodeGeneratorState } from '../ts/interfaces/qr-code-generator-state.tsx';

export function ValidateInput({
  activeTab,
  state,
  setError,
  setBatchData,
  setQrBatchCount,
  dispatch
}: ValidateInputParameters) {
  const isFieldMissing = (field: keyof QRCodeGeneratorState) => !state[field];

  const handleValidationError = (errorMessage: string): boolean => {
    setError(errorMessage);
    resetBatchAndLoadingState({ dispatch, setBatchData, setQrBatchCount });
    return false; // validation failed
  };

  const validateRequiredFields = (): boolean => {
    const requiredFields = requiredFieldsMapping[activeTab];
    if (!requiredFields) {
      return true;
    }

    for (const field of requiredFields.fields) {
      if (isFieldMissing(field as keyof QRCodeGeneratorState)) {
        return handleValidationError(requiredFields.errorMessage);
      }
    }

    // Use the extended mapping for additional validation
    if (requiredFields.validation && !requiredFields.validation(state)) {
      return handleValidationError(
        requiredFields.validationError || 'Invalid input'
      );
    }

    return true;
  };
  const validateEmailFields = (): boolean => {
    if (activeTab !== Tabs.Email) {
      return true;
    }
    if (state.cc && isInvalidEmail(state.cc)) {
      return handleValidationError('One or more CC emails are invalid');
    }
    if (state.bcc && isInvalidEmail(state.bcc)) {
      return handleValidationError('One or more BCC emails are invalid');
    }
    return true; // all emails are valid
  };

  return () => validateRequiredFields() && validateEmailFields();
}
