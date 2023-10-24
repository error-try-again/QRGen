import { V_CARD_VERSION_LIST } from '../../../constants/constants';
import { styles } from '../../../assets/styles';
import { VersionField } from '../../../ts/interfaces/field-interfaces';

export interface VersionSelectorProperties {
  selectedVersion: string;
  handleVersionChange: ({ version }: VersionField) => void;
}

export const VersionSelector = ({
  selectedVersion,
  handleVersionChange
}: VersionSelectorProperties) => {
  const { label, fieldContainer } = styles;
  return (
    <div style={fieldContainer}>
      <p style={label}>vCard Version</p>
      {V_CARD_VERSION_LIST.map(version => (
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
      ))}
    </div>
  );
};
