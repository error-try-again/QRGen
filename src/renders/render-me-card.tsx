import {QRCodeRequest} from "../ts/interfaces/qr-code-request-interfaces";
import React from "react";
import {DESKTOP_MEDIA_QUERY_THRESHOLD} from "../constants/constants";
import {MeCardFields} from "../constants/fields";

interface MeCard {
    renderInputFieldsInColumns: (fields: (keyof QRCodeRequest)[], columns: number) => React.JSX.Element;
}

export function renderMeCard({renderInputFieldsInColumns}: MeCard) {
    function RenderedMeCard() {
        return <>
            {
                // Check the current viewport width.
                // If it's larger or equal to the DESKTOP_MEDIA_QUERY_THRESHOLD, use two columns,
                // otherwise use one column.
                window.innerWidth >= DESKTOP_MEDIA_QUERY_THRESHOLD
                    ? renderInputFieldsInColumns(MeCardFields, 2) // For wider screens (desktop)
                    : renderInputFieldsInColumns(MeCardFields, 1) // For narrower screens (mobile)
            }
        </>;
    }

    RenderedMeCard.displayName = "RenderedMeCard";

    return RenderedMeCard;
}
