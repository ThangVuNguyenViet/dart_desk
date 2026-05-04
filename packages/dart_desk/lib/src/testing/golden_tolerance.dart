/// Per-item pixel tolerance for `flutter_test_goldens` Gallery / Timeline
/// scenes.
///
/// Goldens are generated on `linux/arm64` Docker (Apple Silicon dev hosts) but
/// CI runs on `ubuntu-22.04-arm` (AWS Graviton). Both are ARM64, but Apple's
/// and Graviton's NEON/FMA implementations differ by 1 ULP on a handful of
/// floating-point ops Skia uses for antialiasing. The result is a small
/// scattering of off-by-one pixels (~0.01% of a scene).
///
/// `flutter_test_goldens` defaults gallery tolerance to `0`, so any drift
/// fails. This constant is the per-item tolerance every gallery item should
/// pass to absorb that microarchitectural noise without masking real layout
/// or style regressions (which produce diffs orders of magnitude larger).
const int kGoldenTolerancePx = 500;
