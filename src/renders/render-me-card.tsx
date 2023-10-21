import { DESKTOP_MEDIA_QUERY_THRESHOLD } from '../constants/constants';
import { MeCardFields } from '../constants/fields';
import { MeCardParameters } from '../ts/interfaces/component-interfaces';

export function renderMeCard({ renderInputFieldsInColumns }: MeCardParameters) {
  function RenderedMeCard() {
    return (
      <>
        {
          // Check the current viewport width.
          // If it's larger or equal to the DESKTOP_MEDIA_QUERY_THRESHOLD, use two columns,
          // otherwise use one column.
          window.innerWidth >= DESKTOP_MEDIA_QUERY_THRESHOLD
            ? renderInputFieldsInColumns(MeCardFields, 2) // For wider screens (desktop)
            : renderInputFieldsInColumns(MeCardFields, 1) // For narrower screens (mobile)
        }
      </>
    );
  }

  RenderedMeCard.displayName = 'RenderedMeCard';

  return RenderedMeCard;
}
