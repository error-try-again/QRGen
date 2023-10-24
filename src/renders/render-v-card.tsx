import { styles } from '../assets/styles';
import {
  DESKTOP_MEDIA_QUERY_THRESHOLD,
  V_CARD_VERSION_LIST
} from '../constants/constants';
import { VCardFields } from '../constants/fields';
import { handleVersionSelect } from '../helpers/handle-version-select';
import { useCore } from '../hooks/use-core';
import { RenderFieldsInColumns } from './render-fields-as-cols';
import { useHandleInputChange } from '../hooks/callbacks/use-handle-input-change';

export function RenderVCard() {
  const { dispatch, selectedVersion, setSelectedVersion } = useCore();
  const { label, fieldContainer } = styles;

  const handleVersionChange = handleVersionSelect({
    setSelectedVersion,
    dispatch
  });

  const handleInputChange = useHandleInputChange();

  return (
    <>
      <div style={fieldContainer}>
        <p style={label}>vCard Version</p>
        {V_CARD_VERSION_LIST.map(version => {
          return (
            <div key={version}>
              <input
                type="radio"
                id={`version_${version}`}
                name="version"
                value={version}
                checked={selectedVersion === version}
                onChange={() => {
                  handleVersionChange({ version });
                }}
              />
              <label htmlFor={`version_${version}`}>{version}</label>
            </div>
          );
        })}
      </div>
      <>
        {window.innerWidth >= DESKTOP_MEDIA_QUERY_THRESHOLD ? (
          <RenderFieldsInColumns
            handleInputChange={handleInputChange}
            fields={VCardFields}
            columns={2}
          />
        ) : (
          <RenderFieldsInColumns
            handleInputChange={handleInputChange}
            fields={VCardFields}
            columns={1}
          />
        )}
      </>
    </>
  );
}
