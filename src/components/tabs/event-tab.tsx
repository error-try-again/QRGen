import { useCore } from '../../hooks/use-core';
import { styles } from '../../assets/styles';
import { useHandleInputChange } from '../../hooks/callbacks/use-handle-input-change';
import { Divider } from '../extras/divider';
import { InputFields } from '../../renders/render-input-fields';
import { InputField } from '../fields/input-field';

export const EventTab = () => {
  const { state, setError } = useCore();
  const { sectionTitle, section } = styles;
  const handleInputChange = useHandleInputChange();
  return (
    <section style={section}>
      <h2 style={sectionTitle}>Event</h2>
      <Divider />
      {InputFields({ keys: ['event', 'venue'] })}
      <InputField
        keyName="startTime"
        value={state.startTime}
        handleChange={handleInputChange}
        type="datetime-local"
        setError={setError}
      />
      <InputField
        keyName="endTime"
        value={state.endTime}
        handleChange={handleInputChange}
        type="datetime-local"
        setError={setError}
      />
    </section>
  );
};
