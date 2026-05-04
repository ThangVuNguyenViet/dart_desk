## 0.1.1

 - **FIX**(image_input): deep-equal DeskData.value to stop rebuild churn (#31).
 - **FEAT**(image_input): scale slider in Edit Framing transform mode (#39).
 - **FEAT**: image transform (scale + offset) + slide-over Edit Framing (#35).

## 0.1.0

 - **FEAT**: `DeskFrame` now respects `ImageReference.scale` and `offset`, applying author-defined transforms on top of hotspot/crop framing (#35).
 - **FEAT**: `framing_math` extended with combined scale × offset × hotspot × crop matrix helpers, validated by golden tests in `dart_desk` (#33).
 - **FIX**(image_input): deep-equal `DeskData.value` to stop rebuild churn (#31).
 - **CHORE**: bump `dart_desk_annotation` to `^0.3.0`.

## 0.0.1

- Initial release. Adds `DeskFrame` and `DeskImage` for hotspot/crop-aware rendering of `ImageReference`.
- Houses `framing_math` (relocated from `dart_desk`).
