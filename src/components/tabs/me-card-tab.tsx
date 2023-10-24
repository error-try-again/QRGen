import { styles } from '../../assets/styles';
import { Divider } from '../extras/divider';
import { RenderMeCard } from '../../renders/render-me-card';

export const MeCardTab = () => {
  const { sectionTitle, section } = styles;
  return (
    <section style={section}>
      <h2 style={sectionTitle}>MeCard</h2>
      <Divider />
      <RenderMeCard />
    </section>
  );
};
