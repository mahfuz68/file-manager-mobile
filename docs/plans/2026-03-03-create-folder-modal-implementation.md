# Create Folder Modal Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement a newly designed "Create Folder" modal that matches the @a4.PNG UI design and provides better context for where a folder is being created.

**Architecture:** Create a new custom widget `NewFolderModal` to be displayed via `showModalBottomSheet`. It will use `Provider` to interact with `FileManagerProvider`.

**Tech Stack:** Flutter, Provider, Google Fonts

---

### Task 1: Create `NewFolderModal` Widget Skeleton

**Files:**
- Create: `lib/widgets/new_folder_modal.dart`

**Step 1: Write the minimal component skeleton**
Create `lib/widgets/new_folder_modal.dart` with a `StatefulWidget` that returns a `Container` with the basic dark background and rounded top corners. Include the `_ctrl` for the text field and `_loading`, `_error` states.

**Step 2: Add to `Toolbar` to test opening**
Modify `lib/widgets/toolbar.dart` to use `showModalBottomSheet` with `NewFolderModal` instead of `NewFolderBottomSheet`.
Run app manually to verify it opens.

**Step 3: Commit**
```bash
git add lib/widgets/new_folder_modal.dart lib/widgets/toolbar.dart
git commit -m "feat: add NewFolderModal skeleton and wire to Toolbar"
```

---

### Task 2: Implement Header Section

**Files:**
- Modify: `lib/widgets/new_folder_modal.dart`

**Step 1: Implement the Header UI**
Add the header row: Icon with green border, "Create New Folder" title, "NEW DIRECTORY · CLOUDFLARE R2" subtitle, and close button. Add a divider below.

**Step 2: Commit**
```bash
git add lib/widgets/new_folder_modal.dart
git commit -m "feat: implement header section of new folder modal"
```

---

### Task 3: Implement Context Section (Path Indicator)

**Files:**
- Modify: `lib/widgets/new_folder_modal.dart`

**Step 1: Fetch and Display Current Path**
Use `context.watch<FileManagerProvider>().currentPath` to get the path. Create the dark container with the left green border accent, folder icon, "CREATING INSIDE" label, and the actual path.

**Step 2: Commit**
```bash
git add lib/widgets/new_folder_modal.dart
git commit -m "feat: implement path context section in new folder modal"
```

---

### Task 4: Implement Input Section and Action Buttons

**Files:**
- Modify: `lib/widgets/new_folder_modal.dart`

**Step 1: Implement TextField and Buttons**
Add the "FOLDER NAME" label and styled text field. Add the cancel and create buttons. Connect the text field's `onSubmitted` and the create button's `onPressed` to the `_create` method.

**Step 2: Implement `_create` logic**
Implement validation and the call to `context.read<FileManagerProvider>().createFolder()`. Show errors if any.

**Step 3: Commit**
```bash
git add lib/widgets/new_folder_modal.dart
git commit -m "feat: implement input and actions for new folder modal"
```

---

### Task 5: Cleanup and Final Adjustments

**Files:**
- Modify: `lib/widgets/new_folder_modal.dart`
- Delete (if applicable): `lib/widgets/new_folder_bottom_sheet.dart` (if no longer used anywhere else)

**Step 1: Fine-tune spacing and colors**
Adjust padding, margins, and exact colors to match the design precisely. Ensure the keyboard interaction works smoothly (padding bottom with `viewInsets`).

**Step 2: Remove old component**
If `NewFolderBottomSheet` is unused, delete it to keep the codebase clean.

**Step 3: Commit**
```bash
git add lib/widgets/new_folder_modal.dart
# git rm lib/widgets/new_folder_bottom_sheet.dart # If removing
git commit -m "refactor: finalize styling and remove old bottom sheet"
```
