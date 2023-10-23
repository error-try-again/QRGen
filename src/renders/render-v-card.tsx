import { styles } from '../assets/styles';
import {
  DESKTOP_MEDIA_QUERY_THRESHOLD,
  V_CARD_VERSION_LIST
} from '../constants/constants';
import { VCardFields } from '../constants/fields';
import { handleVersionSelect } from '../helpers/handle-version-select';
import { RenderFieldsAsColumns } from './render-fields-as-cols.tsx';
import { useCore } from '../hooks/use-core.tsx';

export function RenderVCard() {
  const { dispatch, selectedVersion, setSelectedVersion } = useCore();

  const renderInputFieldsInColumns = RenderFieldsAsColumns();

  const handleVersionChange = handleVersionSelect({
    setSelectedVersion,
    dispatch
  });

  const { label, fieldContainer } = styles;

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
      {
        // Check the current viewport width.
        // If it's larger or equal to the DESKTOP_MEDIA_QUERY_THRESHOLD, use 2 columns, otherwise use 1 column.
        window.innerWidth >= DESKTOP_MEDIA_QUERY_THRESHOLD
          ? renderInputFieldsInColumns(VCardFields, 2) // For wider screens (desktop)
          : renderInputFieldsInColumns(VCardFields, 1) // For narrower screens (mobile)
      }
    </>
  );
}
