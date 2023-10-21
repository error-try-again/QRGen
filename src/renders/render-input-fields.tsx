import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces";
import {HandleInputChange} from "../callbacks/handle-input-change";
import {InputField} from "../components/fields/input-field";
import {convertValueToString} from "../utils/convert-to-string";
import {RenderInputFieldsParameters} from "../ts/interfaces/component-interfaces";
import {requiredFieldsMapping} from "../validators/validation-mapping";

export function RenderInputFields({
                                      tab,
                                      state,
                                      dispatch,
                                      setError
                                  }: RenderInputFieldsParameters) {

    const handleInputChange = HandleInputChange({state: state, dispatch: dispatch});

    function isFieldRequired(fieldName: keyof QRCodeRequest): boolean {
        const requiredFields = requiredFieldsMapping[tab]?.fields || [];
        return requiredFields.includes(fieldName as string);
    }

    function RenderedInputFields(keys: (keyof QRCodeRequest)[]) {
        return <>
            {keys.map(key => {

                const convertedValue = convertValueToString({value: state[key]});
                const required = isFieldRequired(key);

                return (
                    <InputField
                        key={key.toString()}
                        keyName={key}
                        value={convertedValue}
                        handleChange={handleInputChange}
                        setError={setError}
                        isRequired={required}
                    />
                );
            })}
            {() => setError("")}
        </>;
    }

    RenderedInputFields.displayName = "RenderedInputFields";

    return RenderedInputFields;
}
