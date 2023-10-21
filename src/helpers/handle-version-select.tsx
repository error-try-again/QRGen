import { HandleVersionSelectParameters } from '../ts/interfaces/component-interfaces';
import { VersionField } from '../ts/interfaces/field-interfaces';

export function handleVersionSelect({
  setSelectedVersion,
  dispatch
}: HandleVersionSelectParameters) {
  return ({ version }: VersionField) => {
    setSelectedVersion(version);
    dispatch({
      field: 'version',
      type: 'SET_FIELD',
      value: version
    });
  };
}
