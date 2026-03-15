# 01 - Sidebar Navigation

## Prerequisites
- App is on the studio screen
- At least one document type is registered ("Test All Fields")

## TC-01-01: Document type is visible in sidebar
**Steps:**
1. Call get_interactive_elements
2. Verify a Text element with "Test All Fields" exists in the sidebar area (x < 300)

**Expected:**
- Text "Test All Fields" is visible
- An icon is displayed next to it

## TC-01-02: Tap document type selects it
**Steps:**
1. Tap "Test All Fields" in the sidebar
2. Call get_interactive_elements

**Expected:**
- "Test All Fields" text color changes to primary (selected state)
- Selection indicator (dot) appears on the sidebar item
- Document list panel shows the "Test All Fields" header

## TC-01-03: Selected type shows document list
**Steps:**
1. Tap "Test All Fields" if not already selected
2. Call get_interactive_elements

**Expected:**
- Document list header shows "Test All Fields"
- Search field with placeholder "Search documents..." is visible
- "+" button is visible in the header
- Pre-seeded documents are listed: "Test Document Alpha", "Test Document Beta", "Test Document Gamma"

## TC-01-04: Re-tapping selected type does not deselect
**Steps:**
1. Tap "Test All Fields" (already selected)
2. Call get_interactive_elements

**Expected:**
- "Test All Fields" remains selected (highlight unchanged)
- Document list still shows the documents
