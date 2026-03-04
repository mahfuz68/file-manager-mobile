# Rename Modal Consistent Buttons Design

## Objective
Make the button layout in the Rename modal consistent with the Delete modal by introducing a two-button (Cancel and action) layout.

## Design
Currently, `RenameBottomSheet` uses a single `SheetPrimaryButton`. We will replace it with a `Row` containing two buttons proportioned like the `DeleteBottomSheet`.

- A `SheetSecondaryButton` labeled "Cancel" wrapped in `Expanded(flex: 1)`.
- A `SheetPrimaryButton` labeled "Rename" wrapped in `Expanded(flex: 2)`.
- The buttons will be separated by a `SizedBox(width: 10)`.

## Implementation Files
- `lib/widgets/rename_bottom_sheet.dart`: Update the action button row.
