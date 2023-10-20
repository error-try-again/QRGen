import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces";
import {HandleInputChange} from "../callbacks/handle-input-change";
import {InputField} from "../components/fields/input-field";
import {convertValueToString} from "../utils/convert-to-string";
import {InputFields} from "../ts/interfaces/component-interfaces.tsx";


export function RenderInputFields(
    {state, dispatch, setError}: InputFields) {

    const handleInputChange = HandleInputChange({state: state, dispatch: dispatch});
    function RenderedInputFields(keys: (keyof QRCodeRequest)[]) {
        return <>
            {keys.map(key => {
                const convertedValue = convertValueToString({value : state[key]});
                return (
                    <InputField key={key.toString()}
                                keyName={key}
                                value={convertedValue}
                                handleChange={handleInputChange}
                                setError={setError}/>
                );
            })}
            {() => setError("")}
        </>;
    }

    RenderedInputFields.displayName = "RenderedInputFields";

    return RenderedInputFields;
}
