# isDefault Document UI — Design Spec

**Date:** 2026-03-31
**Scope:** Frontend (dart_desk) + Backend (dart_desk_be)

---

## Overview

`CmsDocument.isDefault` marks the canonical/fallback document for a given document type. The backend model, ViewModel signal, and `updateMetadata` plumbing already exist. This spec covers surfacing `isDefault` as a fully interactive UI feature in the document list.

---

## Behaviour

- Exactly one document per document type can be the default at any time.
- The first document created for a type is automatically the default.
- If the default document is deleted and one other document remains, that remaining document becomes the default automatically.
- A user can manually change the default via the document tile's overflow menu.
- All cases (manual swap, auto-default on create, auto-default on delete) fire a single toast: **"[Title] is now the default."**

---

## Frontend Changes

### 1. Document Tile — Default Badge

Replace the current 9px muted `"Default"` text label with a `ShadBadge` (secondary variant) in the tile footer row. This applies to whichever document currently has `isDefault == true`.

### 2. Document Tile — Overflow Menu

Add a `⋯` overflow button (`ShadIconButton.ghost`, `ShadButtonSize.sm`) to the top-right of each document tile. Visibility: always visible on mobile; hover-visible on desktop.

The overflow menu (`ShadPopover`) contains:

| Item | State |
|---|---|
| Set as default | Disabled (greyed) if this document is already the default, or is the only document in the type |
| — separator — | |
| Delete | Always enabled (existing behaviour) |

### 3. Toast Feedback

After any operation that changes the default (manual or auto), fire a `ShadToast`:

```
"[Title] is now the default."
```

This covers: manual "Set as default" tap, auto-default on first document created, and auto-default on delete of the previous default.

### 4. ViewModel

`CmsDocumentViewModel` already has an `isDefault` signal. The new `setDefaultDocument` endpoint replaces the existing `updateMetadata` call for this field. No new ViewModel signals needed.

---

## Backend Changes

### 1. New Endpoint: `setDefaultDocument`

```
Future<CmsDocument> setDefaultDocument(
  String documentTypeSlug,
  int documentId,
)
```

- Runs in a single transaction:
  1. Unsets `isDefault` on the current default document for the type (if any).
  2. Sets `isDefault = true` on `documentId`.
- Returns the updated `CmsDocument`.

### 2. Auto-Default on Create

In `createDocument`: if no documents exist yet for the given type, create with `isDefault: true`.

### 3. Auto-Default on Delete

In `deleteDocument`: if the deleted document had `isDefault: true` and exactly one other document remains in the type, set that remaining document's `isDefault = true` in the same transaction.

### 4. DB Constraint: Partial Unique Index

Add via Serverpod migration:

```sql
CREATE UNIQUE INDEX cms_document_one_default_per_type
  ON cms_document (document_type_id)
  WHERE is_default = true;
```

Enforces the single-default-per-type rule at the database level as a safety net.

---

## Out of Scope

- Exposing `isDefault` in the document create form (auto-default handles the first-doc case).
- Exposing `isDefault` in the document editor metadata panel.
- Any mobile-specific layout changes beyond hover→always-visible for the overflow button.
