# Create Folder Modal Redesign

## Overview
Redesign the "New Folder" functionality to use a custom modal bottom sheet that matches the provided UI design (@a4.PNG), offering a more contextual and visually polished experience.

## Architecture & Components
- **Component**: Create a new file `lib/widgets/new_folder_modal.dart` containing a `NewFolderModal` stateful widget.
- **Integration**: Update `Toolbar` (or wherever `NewFolderBottomSheet` is currently invoked) to call `showModalBottomSheet(isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const NewFolderModal())`.
- **State Management**: Use `Provider` to read `FileManagerProvider` for the current path context and to execute the `createFolder` action.

## Visual Design Details (matching @a4.PNG)
- **Container**: Dark background (e.g., `#1A1A1A` or similar from `AppTheme`), rounded top corners.
- **Header Section**:
  - Left: Icon (folder with plus) inside a rounded square with a dark green border.
  - Middle: Title "Create New Folder" (white/light grey), Subtitle "NEW DIRECTORY · CLOUDFLARE R2" (monospace, uppercase, grey).
  - Right: "X" icon button to close.
  - Divider below header.
- **Context Section (Path Indicator)**:
  - Dark container with a subtle green border accent on the left edge.
  - Small folder icon.
  - Text "CREATING INSIDE" (small, monospace, grey).
  - Current path (e.g., `/ (root)`).
- **Input Section**:
  - Label "FOLDER NAME" (small, monospace, letter-spaced).
  - TextField with dark background, rounded corners, "e.g. documents, images, 2026..." hint text.
  - Divider below input section.
- **Action Buttons**:
  - Row layout.
  - Left: "Cancel" button (dark grey background).
  - Right: "Create Folder" button (dark green background with folder icon).

## Data Flow & Error Handling
- The modal reads `FileManagerProvider.currentPath` to display in the context section.
- On submit, validates input (not empty, no invalid characters like `/` or `..`).
- Calls `context.read<FileManagerProvider>().createFolder(name)`.
- Displays inline error message (using existing `SheetErrorBanner` or similar) if validation or API call fails.
- Closes the modal on success.
