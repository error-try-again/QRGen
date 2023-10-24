import { useCore } from '../../hooks/use-core';
import { styles } from '../../assets/styles';
import { useHandleInputChange } from '../../hooks/callbacks/use-handle-input-change';
import { Divider } from '../extras/divider';
import { InputField } from '../fields/input-field';
import { isFieldRequired } from '../../helpers/is-field-required';
import { Tabs } from '../../ts/enums/tabs-enum';
import { ChangeEvent } from 'react';

export const SmsTab = () => {
  const { state, setError } = useCore();
  const { section, sectionTitle, fieldContainer, label, input } = styles;
  const handleInputChange = useHandleInputChange();
  return (
    <section style={section}>
      <h2 style={sectionTitle}>SMS</h2>
      <Divider />
      <InputField
        isRequired={isFieldRequired(Tabs.SMS, 'phone')}
        keyName="phone"
        value={state.phone}
        handleChange={handleInputChange}
        setError={setError}
      />
      <div style={fieldContainer}>
        <label
          style={label}
          htmlFor="smsMessage"
        >
          Enter SMS Message
        </label>
        <textarea
          id="smsMessage"
          style={{ ...input, height: '100px' }}
          value={state.sms || ''}
          onChange={(event: ChangeEvent<HTMLTextAreaElement>) =>
            handleInputChange(event, 'sms')
          }
          placeholder="Enter your SMS message here"
        />
      </div>
    </section>
  );
};
