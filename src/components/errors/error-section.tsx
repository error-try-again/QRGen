import { useCore } from '../../hooks/use-core';
import { styles } from '../../assets/styles';

export function ErrorSection() {
  const { errorContainer } = styles;
  const { error } = useCore();
  return <> {error && <div style={errorContainer}>{error}</div>}</>;
}
