import { MeCardFields, VCardFields } from '../constants/fields';
import { useHandleInputChange } from '../hooks/callbacks/use-handle-input-change';
import { useCore } from '../hooks/use-core';
import { handleVersionSelect } from '../helpers/handle-version-select';
import { VersionSelector } from '../components/buttons/radio/version-selector';
import { ResponsiveRenderer } from './responsive-renderer';

export function RenderVCard() {
  const { dispatch, selectedVersion, setSelectedVersion } = useCore();
  const handleVersionChange = handleVersionSelect({
    setSelectedVersion,
    dispatch
  });

  return (
    <>
      <VersionSelector
        selectedVersion={selectedVersion}
        handleVersionChange={handleVersionChange}
      />
      <ResponsiveRenderer
        handleInputChange={useHandleInputChange()}
        fields={VCardFields}
      />
    </>
  );
}

export const RenderMeCard = () => (
  <ResponsiveRenderer
    handleInputChange={useHandleInputChange()}
    fields={MeCardFields}
  />
);
