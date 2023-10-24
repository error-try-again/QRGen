import { styles } from '../../assets/styles';
import { Divider } from '../extras/divider';
import { RenderVCard } from '../../renders/render-v-card';

export const VCardTab = () => {
  const { section, sectionTitle } = styles;
  return (
    <section style={section}>
      <h2 style={sectionTitle}>VCard</h2>
      <Divider />
      <RenderVCard />
    </section>
  );
};
