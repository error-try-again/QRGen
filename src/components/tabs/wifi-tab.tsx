import { useCore } from '../../hooks/use-core';
import { styles } from '../../assets/styles';
import { useHandleInputChange } from '../../hooks/callbacks/use-handle-input-change';
import { Divider } from '../extras/divider';
import { DropdownField } from '../fields/dropdown-field';
import { InputFields } from '../../renders/render-input-fields';

export const WiFiTab = () => {
  const { state, setError } = useCore();

  const { sectionTitle, section } = styles;
  const handleInputChange = useHandleInputChange();
  return (
    <section style={section}>
      <h2 style={sectionTitle}>WiFi Configuration</h2>
      <Divider />
      {InputFields({ keys: ['ssid', 'password'] })}
      <DropdownField
        keyName="encryption"
        handleChange={handleInputChange}
        options={['WEP', 'WPA', 'WPA2', 'WPA3']}
        value={state.encryption || ''}
        setError={setError}
      />
      <DropdownField
        keyName="hidden"
        handleChange={handleInputChange}
        options={['true', 'false']}
        value={state.hidden ? 'true' : 'false'}
        setError={setError}
      />
    </section>
  );
};
