import {HandleVersionSelectParameters} from "../ts/interfaces/component-interfaces.tsx";
import {VersionField} from "../ts/interfaces/field-interfaces.tsx";

export function handleVersionSelect({setSelectedVersion, dispatch}: HandleVersionSelectParameters) {
    return ({version}: VersionField) => {
        setSelectedVersion(version);
        dispatch({
            field: 'version',
            type: 'SET_FIELD',
            value: version
        });
    };
}
